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

class NewsViewController : UIViewController, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate, rssPopoverNavDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var newsTableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var noDataLabel: UILabel!
    private var didRemoveLast: Bool!
    private var didRemoveLastOfSection: Bool!
    private var imageCache: NSCache!
    
    private var popOverNavController: UINavigationController!
    private var popoverContent: NewsPopoverViewController!
    private var popOverVC: UIPopoverController!
    
    private var feedDetailVC: FeedViewController!
    
    private var sectionsInTable: [RSSType]!
    
    private var newNewsObject: RSSFeed!
    private var newsManager: NewsManager!
    private var newsList: [RSSFeed]!
    private var indexPendingDelete: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newNewsObject = nil
        newsManager = NewsManager()
        newsList = []
        sectionsInTable = []
        didRemoveLast = false
        imageCache = NSCache()
        
        newsTableView.registerNib(UINib(nibName: "NewsViewCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.allowsMultipleSelectionDuringEditing = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = gmLightBlueColor;
        self.refreshControl.tintColor = UIColor.whiteColor();
        self.refreshControl.addTarget(newsManager, action: Selector("getAllFeedsRequest"), forControlEvents: UIControlEvents.ValueChanged)
        self.newsTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.title = newsTitle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name: kNetworkError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInternalServerError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInvalidFeedResponse, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedFeedAdded:", name: kNewsAdded, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedListUpdate:", name: kFeedListUpdated, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(!Reachability.isConnectedToNetwork()) {
            SCLAlertView().showNotice(internetErrTitle,
                subTitle: internetErrMessage,
                duration: 6)
        } else {
            if(self.newsList.count == 0) {
                newsManager.getAllFeedsRequest()
            }
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
        SCLAlertView().showWarning(internalErrTitle,
            subTitle:  reason + " - " + message, closeButtonTitle: dismissButTitle)
        self.reloadNewsData()
    }
    
    func receivedFeedAdded(notification: NSNotification) {
        let resultDic = notification.userInfo as Dictionary<String, Bool>
        let result: Bool = resultDic["success"]!
        
        if result {            
            newsManager.getAllFeedsRequest()
            self.refreshControl.beginRefreshing()
            self.newsTableView.setContentOffset(CGPointMake(0, -self.refreshControl.frame.size.height), animated:true)
        } else {
            SCLAlertView().showWarning("Feed Create Failed", subTitle: "An unknown error occured", closeButtonTitle: dismissButTitle)
        }
    }
    
    func receivedListUpdate(notification: NSNotification) {
        let feedDictionary = notification.userInfo as Dictionary<String,RSSFeed>
        self.newsList = []
        
        for feed in feedDictionary.values {
            self.newsList.append(feed)
            var type = feed.type
            
            if !contains(self.sectionsInTable, type) {
                self.sectionsInTable.append(type)
            }
        }
        
        self.reloadNewsData()
    }

    
    func getItemsForSection(section: Int) -> [RSSFeed] {
        var sectionsArray = [RSSFeed]()
        
        for feed in self.newsList {
            
            var type = feed.type
            if(type == sectionsInTable[section]) {
                sectionsArray.append(feed)
            }
        }
        
        return sectionsArray
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
            
            var nextButton = UIBarButtonItem(title: nextButTitle, style: UIBarButtonItemStyle.Bordered, target: self.popoverContent, action: Selector("nextTapped:"))
            
            var cancelButton = UIBarButtonItem(title: cancelButTitle, style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("cancelNewsTapped:"))
            
            self.popoverContent.navigationItem.title = newNewsFeedTitle
            self.popoverContent.navigationItem.rightBarButtonItem = nextButton
            self.popoverContent.navigationItem.leftBarButtonItem = cancelButton
        }
        
        if(self.popOverVC == nil) {
            self.popOverVC = UIPopoverController(contentViewController: popOverNavController)
        }
        
        self.popOverVC.popoverContentSize = CGSize(width: 400, height: 500)
        
        let rect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 1, 1)
        
        self.popOverVC.delegate = self
        self.popOverVC.presentPopoverFromRect(rect, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.allZeros, animated: true)
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
        
        let sectionItems = self.getItemsForSection(indexPath.section)
        
        let feed: RSSFeed = sectionItems[indexPath.row]
        
        cell.setNewsFeed(feed)
        
        var longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPressNewsCell:"))
        longPress.minimumPressDuration = 2.0
        cell.contentView.addGestureRecognizer(longPress)
        
        var image: UIImage? = self.imageCache.objectForKey(feed.id) as? UIImage
        
        if(image != nil) {
            cell.setThumbnailLogo(image!)
            
        } else {
            cell.setThumbnailLogo(nil)
            
            if feed.logoURL != "" {
                var q: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_async(q, {

                    var image = (UIImage(named: "gm_unknown")!)
                    
                    let url = NSURL(string: feed.logoURL)
                    if url != nil {
                        if let data = NSData(contentsOfURL: url!) {
                            image = (UIImage(data: data)!)
                        }
                    }
                    
                    self.imageCache.setObject(image, forKey: feed.id)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.setThumbnailLogo(image)
                    })
                })
            } else {
                cell.setThumbnailLogo((UIImage(named: "gm_unknown")!))
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.newsList.count > 0 || didRemoveLast == true) {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
            
            if(noDataLabel != nil) {
                tableView.backgroundView = nil
                noDataLabel = nil
            }

            return sectionsInTable.count;
        }
        
        noDataLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        noDataLabel.text = noFeedsMessage
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
        return self.getItemsForSection(section).count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var type = sectionsInTable[section]
        
        if type == RSSType.OTHER {
            return " Other"
        }
        
        return " " + type.rawValue
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       var type = sectionsInTable[section]
        if(isGroupEmpty(type)) {
            return 0
        }

        return 35
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
        if(self.feedDetailVC == nil) {
            self.feedDetailVC = FeedViewController(nibName: "FeedViewController", bundle: nil)
        }
        
        self.feedDetailVC.configure(cell.getNewsFeedObject(), WithManager: newsManager)
        self.navigationController?.pushViewController(feedDetailVC, animated: true)
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = gmLightBlueColor
        
        var header: UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor.whiteColor()
    }
    
    //MARK: - Custom Delegate
    
    func saveFeed(feed: RSSFeed) {
        self.popOverVC.dismissPopoverAnimated(true)
        self.newsManager.saveValidFeedToServer(feed)
    }
    
    //MARK: - UITapGestureRecognizer
    
    func longPressNewsCell(sender: UILongPressGestureRecognizer) {
        
        if(sender.state == UIGestureRecognizerState.Ended) {
            let point: CGPoint = sender.locationInView(self.newsTableView)
            let indexPath: NSIndexPath = self.newsTableView.indexPathForRowAtPoint(point)!
            //var tableViewCell: NewsViewCell = self.tasksTableView.cellForRowAtIndexPath(indexPath) as NewsViewCell!
            
            self.indexPendingDelete = indexPath
            
            let actionSheet = UIActionSheet(title: deleteFeedMessage, delegate: self, cancelButtonTitle: cancelButTitle, destructiveButtonTitle: deleteFeedTitle)
            actionSheet.addButtonWithTitle(cancelButTitle)
            actionSheet.actionSheetStyle = .BlackOpaque
            actionSheet.showInView(self.view)
        }
    }
    
    // MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
  
        if(buttonIndex == 0 && indexPendingDelete != nil) {
            var index: Int = indexPendingDelete.row
            newsManager.deleteFeedRequest(newsList[index])
            var type = newsList[index].type
            
            if(index == 0) {
                didRemoveLast = true
            } else {
                didRemoveLast = false
            }
            
            self.newsTableView.beginUpdates()
            newsList.removeAtIndex(index)
            
            self.newsTableView.deleteRowsAtIndexPaths([indexPendingDelete], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.newsTableView.endUpdates()
        }
        
        indexPendingDelete = nil
        actionSheet.dismissWithClickedButtonIndex(buttonIndex, animated: true)
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if(buttonIndex == 0 && didRemoveLast == true) {
            didRemoveLast = false
            self.newsTableView.reloadData()
        }
    }

    func isGroupEmpty(type: RSSType) -> Bool {
        for feed in newsList {
            if feed.type == type {
                return false
            }
        }
        
        return true
    }
}