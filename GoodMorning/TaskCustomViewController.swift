//
//  TaskCustomViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-04-14.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskCustomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var deepUrlTable: UITableView!
    
    var selectedLink: String = "None"
    
    var delegate: popOverNavDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Application To Launch"
        
        self.deepUrlTable.dataSource = self
        self.deepUrlTable.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.deepUrlTable.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if(self.selectedLink == "") {
            delegate?.saveCustom("None")
        } else {
            delegate?.saveCustom(self.selectedLink)
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setSelectedItem(link: String) {
        self.selectedLink = link
    }
    
    // MARK: - UITableView Datasource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "alertCell")
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        cell.tintColor = gmOrangeColor
        
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.font = gmFontNormal
        
        var linkType = DeepLinkType.displayValues[indexPath.row]
        
        cell.textLabel?.text = linkType
        
        if(self.selectedLink.lowercaseString == linkType.lowercaseString) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeepLinkType.displayValues.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK : - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let select = DeepLinkType.displayValues[indexPath.row]
        
        if(self.selectedLink.lowercaseString == select.lowercaseString) {
            self.selectedLink = ""
        } else {
            self.selectedLink = select
        }
        
        self.deepUrlTable.reloadData()
    }


}
