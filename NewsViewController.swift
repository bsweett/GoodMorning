//
//  NewsViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

protocol rssPopoverNavDelegate {
    func saveFeed(fedd: RSSFeed)
}

class NewsViewController : UIViewController, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, rssPopoverNavDelegate {
    
    @IBOutlet weak var newsTableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var noDataLabel: UILabel!
    
    private var popOverNavController: UINavigationController!
    private var popoverContent: NewsPopoverViewController!
    private var popOverVC: UIPopoverController!
    
    private var newNewsObject: RSSFeed!
    private var newsManager: NewsManager!
    private var newsList: [RSSFeed]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newNewsObject = nil
        newsManager = NewsManager()
        newsList = []
        
        newsTableView.registerNib(UINib(nibName: "NewsViewCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.allowsMultipleSelectionDuringEditing = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = gmOrangeColor;
        self.refreshControl.tintColor = UIColor.whiteColor();
        self.refreshControl.addTarget(newsManager, action: Selector("getAllFeedsRequest"), forControlEvents: UIControlEvents.ValueChanged)
        self.newsTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.title = "News"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InvalidFeedResponse", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedFeedAdded:", name:"NewsAdded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedListUpdate:", name:"FeedListUpdated", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!Reachability.isConnectedToNetwork()) {
            SCLAlertView().showNotice("No Network Connection",
                subTitle: "You don't appear to be connected to the Internet. Please check your connection.",
                duration: 6)
        } else {
            newsManager.getAllFeedsRequest()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadNewsData() {
        self.newsTableView.reloadData()
        
        if(self.refreshControl != nil) {
            var formatter = NSDateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
            let title: String = String(format: "Last update: %@", formatter.stringFromDate(NSDate()))
            var dictionary: Dictionary = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            var attributedString: NSAttributedString = NSAttributedString(string: title, attributes: dictionary)
            self.refreshControl.attributedTitle = attributedString
            
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Notifications
    
    func receivedNetworkError(notification: NSNotification) {
        /*SCLAlertView().showError("Network Error",
            subTitle: "Oops something went wrong",
            closeButtonTitle: "Dismiss")*/
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        //stopLoading()
        let reason = getUserInfoValueForKey(notification.userInfo, "reason")
        let message = getUserInfoValueForKey(notification.userInfo, "message")
        SCLAlertView().showWarning("Internal Server Error",
            subTitle:  reason + " - " + message, closeButtonTitle: "Dismiss")
        self.reloadNewsData()
    }
    
    func receivedFeedAdded(notification: NSNotification) {
        let resultDic = notification.userInfo as Dictionary<String, Bool>
        let result: Bool = resultDic["success"]!
        
        if result {
            self.refreshControl.beginRefreshing()
        } else {
            SCLAlertView().showWarning("Feed Create Failed", subTitle: "An unknown error occured", closeButtonTitle: "Dismiss")
        }
    }
    
    func receivedListUpdate(notification: NSNotification) {
        let feedDictionary = notification.userInfo as Dictionary<String,RSSFeed>
        self.newsList = []
        
        for feed in feedDictionary.values {
            self.newsList.append(feed)
        }
        
        self.reloadNewsData()
    }
    
    //MARK: - Actions
    
    @IBAction func addNewRSSFeed(sender: UIBarButtonItem) {
        if(self.popoverContent == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.popoverContent = NewsPopoverViewController(nibName: "NewsPopoverViewController", bundle: nil)
        }
        
        popoverContent.rootViewController = self;
        
        if(self.popOverNavController == nil) {
            self.popOverNavController = UINavigationController(rootViewController: popoverContent)
            
            var nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Bordered, target: self.popoverContent, action: Selector("nextTapped:"))
            
            var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("cancelNewsTapped:"))
            
            self.popoverContent.navigationItem.title = "New News Feed"
            self.popoverContent.navigationItem.rightBarButtonItem = nextButton
            self.popoverContent.navigationItem.leftBarButtonItem = cancelButton
        }
        
        if(self.popOverVC == nil) {
            self.popOverVC = UIPopoverController(contentViewController: popOverNavController)
        }
        
        self.popOverVC.popoverContentSize = CGSize(width: 400, height: 450)
        
        self.popOverVC.delegate = self
        self.popOverVC.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
    }
    
    @IBAction func cancelNewsTapped(sender: UIBarButtonItem) {
        if(self.popOverVC != nil) {
            // Clear all fields here?
            // Or overwrite defualt values on viewDidLoad?
            self.popOverVC.dismissPopoverAnimated(true)
        }
    }

    // MARK: - UIPopOverController Delegate
    
    func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
        
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: NewsViewCell = tableView.dequeueReusableCellWithIdentifier("newsCell") as NewsViewCell!
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        cell.setNewsFeed(newsList[indexPath.row])
        
        /*
        var longpress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("taskCellLongPress:"))
        longpress.minimumPressDuration = 2
        cell.contentView.addGestureRecognizer(longpress)*/
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.newsList.count > 0) {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
            
            if(noDataLabel != nil) {
                tableView.backgroundView = nil
                noDataLabel = nil
            }
            
            return 1;
        }
        
        noDataLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        noDataLabel.text = "No News Feeds found. Pull down to refresh or press the + to add one."
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
        return newsList.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            
        }
    }
    
    //MARK: - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as NewsViewCell!
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // TODO: Prompt action sheet for edit or delete
        
    }
    
    //MARK: - Custom Delegate
    
    func saveFeed(feed: RSSFeed) {
        self.popOverVC.dismissPopoverAnimated(true)
        newsManager.saveValidFeedToServer(feed)
    }

}