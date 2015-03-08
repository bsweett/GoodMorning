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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InvalidFeedResponse", object: nil)
        
        titleLabel.text = article.title
        //titleLabel.sizeToFit()
        let titleHeight = titleLabel.frame.size.height
        
        detailLabel.text = rssfeed.title + " / by " + article.creator + " / " + article.pubdate.toFullDateString()
        //detailLabel.sizeToFit()
        let detailHeight = titleLabel.frame.size.height
        
        if(article.image != nil) {
            mainImageView.image = article.image
        }
        
        let imageViewHeight = mainImageView.frame.size.height
        
        if(article.link == nil) {
            websiteButton.enabled = false
        }
        
        contentLabel.text = article.textDescription
        //contentLabel.sizeToFit()
        let contentHeight = titleLabel.frame.size.height
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, titleHeight + detailHeight + imageViewHeight + contentHeight)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layoutSubviews()
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

}
