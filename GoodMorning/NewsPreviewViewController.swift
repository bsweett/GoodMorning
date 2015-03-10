//
//  NewsPreviewViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-15.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class NewsPreviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var channelLogoView: UIImageView!
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var rssChannel: RSSFeed?
    private var rssLogo: UIImage?
    var delegate: rssPopoverNavDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Preview"
        var saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("saveFeed:"))
        self.navigationItem.rightBarButtonItem = saveButton
        
        channelTableView.dataSource = self
        channelTableView.delegate = self
        channelTableView.registerNib(UINib(nibName: "PopoverViewCell", bundle: nil), forCellReuseIdentifier: "taskPopoverCell")
        channelTableView.estimatedRowHeight = 44
        channelTableView.allowsSelection = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if rssChannel == nil {
            channelTableView.hidden = true
            channelLogoView.hidden = true
            titleLabel.text = "The link you provided did not return a valid rss feed"
            descriptionLabel.text = ""
            self.navigationItem.rightBarButtonItem?.enabled = false
        } else {
            channelTableView.hidden = false
            channelLogoView.hidden = false
            self.navigationItem.rightBarButtonItem?.enabled = true
            titleLabel.text = rssChannel?.title
            descriptionLabel.text = rssChannel?.contentDescription
            channelTableView.reloadData()
            channelLogoView.image = self.rssLogo
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setRSSFeed(feed: RSSFeed?, rssLogo: UIImage?) {
        self.rssChannel = feed
        self.rssLogo = rssLogo
    }
    
    @IBAction func saveFeed(sender: UIBarButtonItem) {
        println("Save tapped")
        delegate?.saveFeed(self.rssChannel!)
    }
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PopoverViewCell = tableView.dequeueReusableCellWithIdentifier("taskPopoverCell") as PopoverViewCell!
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        cell.textLabel?.font = gmFontNormal
        cell.hideArrowImageView()
        
        if(self.rssChannel != nil) {
            switch(indexPath.row) {
            case 0:
                cell.setTitle("Website")
                cell.setValue(rssChannel!.link)
                break
            case 1:
                cell.setTitle("Last Updated")
                cell.setValue(rssChannel!.lastActiveDate.toFullDateString())
                break
            case 2:
                cell.setTitle("Type")
                cell.setValue(rssChannel!.type.rawValue)
                break
            default:
                break
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}
