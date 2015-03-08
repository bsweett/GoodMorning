//
//  WebViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-07.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var articleWebView: UIWebView!
    @IBOutlet weak var progressBar: UIProgressView!
    private var isDoneLoading: Bool!
    private var myTimer: NSTimer!
    
    private var nsUrl: NSURL!
    
    private var currentProgress: Float!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articleWebView.delegate = self
        currentProgress = 0.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(nsUrl != nil) {
            let request: NSURLRequest = NSURLRequest(URL: nsUrl, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            articleWebView.loadRequest(request)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.isMovingFromParentViewController()) {
            self.nsUrl = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUrl(url: String) {
        NSLog(url)
        self.nsUrl = NSURL(string: url)
    }
    
    @IBAction func closePageTapped(sender: UIBarButtonItem) {
        articleWebView.loadHTMLString("", baseURL: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func timerCallBack() {
        if(isDoneLoading == true) {
            if (progressBar.progress >= 1) {
                //progressBar.hidden = true;
                myTimer.invalidate()
            } else {
                progressBar.progress += 0.1;
            }
        } else {
            progressBar.progress += 0.05
            if(progressBar.progress >= 0.95) {
                progressBar.progress = 0.95
            }
        }
    }
    
    //MARK: - WebView Delegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        //progressBar.hidden = false
        progressBar.progress = 0
        isDoneLoading = false
        
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: Selector("timerCallBack"), userInfo: nil, repeats: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        isDoneLoading = true
        println("done")
    }

}
