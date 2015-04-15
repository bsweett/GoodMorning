//
//  ArticleViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-07.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var websiteButton: UIButton!
    
    private var newsManager: NewsManager!
    private var rssfeed: RSSFeed!
    private var article: RSSArticle!
    
    private var websiteWebView: WebViewController!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name: kNetworkError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInternalServerError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInvalidFeedResponse, object: nil)
        
        titleLabel.text = article.title
        
        detailLabel.text = rssfeed.title + " / by " + article.creator + " / " + article.pubdate.toFullDateString()
        
        
        if(article.image != nil) {
            mainImageView.image = article.image
        }
        
        if(article.link == nil) {
            websiteButton.enabled = false
        }
        
        var range = article.textDescription.rangeOfString("^\\s*", options: NSStringCompareOptions.RegularExpressionSearch)
        var trimmedContent = article.textDescription.stringByReplacingCharactersInRange(range!, withString: "")
        let spacedContent = trimmedContent.stringByReplacingOccurrencesOfString("  ", withString: "\n\n")
        contentLabel.text = spacedContent

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentHeight = contentLabel.frame.size.height
        let titleHeight = titleLabel.frame.size.height
        let imageViewHeight = mainImageView.frame.size.height
        let detailHeight = detailLabel.frame.size.height
        let buttonHeight = websiteButton.frame.size.height
        let spacing = self.contentView.frame.size.height - titleHeight - detailHeight - imageViewHeight - contentHeight - buttonHeight
        
        self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, self.contentView.frame.size.height + contentHeight - (buttonHeight*6))
        //self.view.layoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(article: RSSArticle, withFeed rssFeed: RSSFeed, withManager manager: NewsManager) {
        self.article = article
        self.rssfeed = rssFeed
        self.newsManager = manager
    }
    
    @IBAction func websiteButtonTapped(sender: UIButton) {
        if(self.websiteWebView == nil) {
            self.websiteWebView = WebViewController(nibName: "WebViewController", bundle: nil)
        }
        
        self.websiteWebView.setUrl(article.link)
        self.websiteWebView.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.websiteWebView.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        self.navigationController?.presentViewController(websiteWebView, animated: true, completion: nil)
    }
    
    func receivedNetworkError(notif: NSNotification) {
        
    }
    
    func receivedInternalServerError(notif: NSNotification) {
        
    }

}
