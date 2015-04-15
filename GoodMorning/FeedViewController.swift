//
//  FeedViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-24.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var articleTableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var noDataLabel: UILabel!
    
    private var rssfeed: RSSFeed! = nil
    private var newsManager: NewsManager! = nil
    private var articleList: [RSSArticle] = []
    
    private var firstTimeAppear: Bool = true
    private var imageCache: NSCache!
    
    private var articleViewController: ArticleViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.articleList = []
        
        articleTableView.registerNib(UINib(nibName: "ArticleViewCell", bundle: nil), forCellReuseIdentifier: "articleCell")
        articleTableView.dataSource = self
        articleTableView.delegate = self

        imageCache = NSCache()
        
        self.refreshControl = UIRefreshControl()
        
        var formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
        let title: String = String(format: "Last update: %@", formatter.stringFromDate(NSDate()))
        var dictionary: Dictionary = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        var attributedString: NSAttributedString = NSAttributedString(string: title, attributes: dictionary)
        
        self.refreshControl.backgroundColor = gmLightBlueColor;
        self.refreshControl.tintColor = UIColor.whiteColor();
        self.refreshControl.addTarget(self, action: Selector("updateArticles"), forControlEvents: UIControlEvents.ValueChanged)
        self.articleTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = rssfeed.title
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InvalidFeedResponse", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedListUpdate:", name:"ArticleListUpdated", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(firstTimeAppear == true) {
            newsManager.getArticlesForFeed(self.rssfeed)
            self.refreshControl.beginRefreshing()
            self.articleTableView.setContentOffset(CGPointMake(0, -self.refreshControl.frame.size.height), animated:true)
            firstTimeAppear = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.isMovingFromParentViewController()) {
            self.articleList = []
            self.rssfeed = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configure(rssfeed: RSSFeed, WithManager manager: NewsManager) {
        self.rssfeed = rssfeed
        self.newsManager = manager
    }
    
    func updateArticles() {
        newsManager.getArticlesForFeed(self.rssfeed)
    }

    func reloadArticleData() {
        self.articleTableView.reloadData()
        
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
        self.reloadArticleData()
    }
    
    func receivedListUpdate(notification: NSNotification) {
        let articleDictionary = notification.userInfo as Dictionary<String,RSSArticle>
        self.articleList = []
        
        for article in articleDictionary.values {
            self.articleList.append(article)
        }
        
        self.reloadArticleData()
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ArticleViewCell = tableView.dequeueReusableCellWithIdentifier("articleCell") as ArticleViewCell!
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        let article = articleList[indexPath.row]
        
        cell.setArticle(article)
        
        var image: UIImage? = self.imageCache.objectForKey(article.title) as? UIImage
        
        if(image != nil) {
            cell.setThumbNailImage(image)
            
        } else {
            
            cell.setThumbNailImage(nil)
            
            if article.thumbnailURL != "" {
                var q: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_async(q, {
                    /* Fetch the image from the server... */
                    var image = (UIImage(named: "gm_unknown")!)
                    
                    let url = NSURL(string: article.thumbnailURL)
                    if url != nil {
                        if let data = NSData(contentsOfURL: url!) {
                            image = (UIImage(data: data)!)
                        }
                    }
                    
                    self.imageCache.setObject(image, forKey: article.title)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        /* This is the main thread again, where we set the tableView's image to
                        be what we just fetched. */
                        cell.setThumbNailImage(image)
                    });
                });
            } else {
                cell.setThumbNailImage((UIImage(named: "gm_unknown")!))
            }
            
        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.articleList.count > 0) {
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
        return articleList.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    //MARK: - UITableView Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as ArticleViewCell!
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //TODO: Push RSS story view and have a link at the bottom to the full webiste story
        if(self.articleViewController == nil) {
            self.articleViewController = ArticleViewController(nibName: "ArticleViewController", bundle: nil)
        }
        
        self.articleViewController.configure(cell.getArticle(), withFeed: self.rssfeed, withManager: self.newsManager)
        self.navigationController?.pushViewController(articleViewController, animated: true)
    }
    
}
