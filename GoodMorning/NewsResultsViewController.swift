//
//  NewsResultsViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-09.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class NewsResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var resultTableView: UITableView!
    private var noDataLabel: UILabel!
    
    var previewVC: NewsPreviewViewController!
    
    var rootViewController: NewsViewController!
    
    private var resultData: [RSSFeed]! = []
    private var imageCache: NSCache!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCache = NSCache()
        
        resultTableView.dataSource = self
        resultTableView.delegate = self
        
        var backButton = UIBarButtonItem(title: backButTitle, style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.resultTableView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setRoot(newsVC: NewsViewController!) {
        self.rootViewController = newsVC
    }
    
    func setResultList(rssfeeds: [RSSFeed]!) {
        resultData = rssfeeds
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "resultCell")
  
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        cell.tintColor = gmOrangeColor
        
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.font = gmFontNormal
        
        let feed = resultData[indexPath.row]
        
        cell.textLabel?.text = feed.title
        
        var image: UIImage? = self.imageCache.objectForKey(feed.title) as? UIImage
        
        if(image != nil) {
            cell.imageView?.image = image
            
        } else {
            
            cell.imageView?.image = nil
            
            if feed.logoURL != "" {
                var q: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_async(q, {
                    /* Fetch the image from the server... */
                    var image = (UIImage(named: "gm_unknown")!)
                    
                    let url = feed.logoAsUrl()
                    if url != nil {
                        if let data = NSData(contentsOfURL: url!) {
                            image = (UIImage(data: data)!)
                        }
                    }
                    
                    self.imageCache.setObject(image, forKey: feed.title)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        (cell.imageView?.image = image)!
                    }
                })
            } else {
                cell.imageView?.image = UIImage(named: "gm_unknown")
            }
            
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.resultData.count > 0) {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
            
            if(noDataLabel != nil) {
                tableView.backgroundView = nil
                noDataLabel = nil
            }
            
            return 1;
        }
        
        noDataLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        noDataLabel.text = "No Articles Found."
        noDataLabel.textColor = gmOrangeColor
        noDataLabel.numberOfLines = 0
        noDataLabel.textAlignment = NSTextAlignment.Center
        noDataLabel.font = gmFontQuoteLarge
        noDataLabel.sizeToFit()
        
        tableView.backgroundView = noDataLabel
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        return 0;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    //MARK: - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if(self.previewVC == nil) {
            self.previewVC = NewsPreviewViewController(nibName: "NewsPreviewViewController", bundle: nil)
        }
        
        self.previewVC.setRSSFeed(resultData[indexPath.row], rssLogo: cell.imageView?.image)
        self.previewVC.delegate = rootViewController
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
}
