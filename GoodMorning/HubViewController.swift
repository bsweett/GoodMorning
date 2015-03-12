//
//  HubViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-11.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore
import DTIActivityIndicator
import CoreData

class HubViewController: UIViewController {
    
    private var firstAppear: Bool = false
    private var alarmDict: Dictionary<String, Task> = [:]
    
    private var blur: UIVisualEffectView!
    private var darkBlur: UIVisualEffectView!
    
    @IBOutlet weak var activityIndicator: DTIActivityIndicatorView!
    @IBOutlet var background: UIImageView!
    
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var weatherView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var alarmsView: UIView!
    
    private var articles: [NSManagedObject]!
    private var articleDisplayTimer: NSTimer!
    private var currentArticleIndex: Int!
    var imageCache: NSCache!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articles = [NSManagedObject]()
        currentArticleIndex = -1
        imageCache = NSCache()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        darkBlur = UIVisualEffectView(effect: blurEffect)
        self.darkBlur.frame = self.view.bounds //view is self.view in a UIViewController
        //self.background.addSubview(self.darkBlur)
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = view.frame
        blur.tag = 51
        
        LocationManager.sharedInstance.update()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name:"WeatherUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBackground", name: "NightCachedChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAlarms:", name: "AlarmListUpdated", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDenied", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDisabled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name:"LocationUnknown", object: nil)
        
        self.parentViewController?.title = "Hub"
        
        
        //updateBackground()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(firstAppear == false) {
            firstAppear = true
            
            if(!Reachability.isConnectedToNetwork()) {
                startLoading()
                stopLoading()
                
                SCLAlertView().showNotice("No Network Connection",
                    subTitle: "You don't appear to be connected to the Internet. Please check your connection.",
                    duration: 6)
            } else {
                
                //startLoading()
                //alarmManger.getAllAlarmsRequest()
            }
        }
        
        checkCoreDataForWeather()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        roundViewBackgrounds()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func roundViewBackgrounds() {
        
        newsView.layer.cornerRadius = radius
        weatherView.layer.cornerRadius = radius
        alarmsView.layer.cornerRadius = radius
        
        newsView.clipsToBounds = true
        weatherView.clipsToBounds = true
        alarmsView.clipsToBounds = true
        
    }
    
    func startLoading() {
        self.view.addSubview(blur)
        self.view.bringSubviewToFront(blur)
        activityIndicator.startActivity()
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    func stopLoading() {
        self.view.sendSubviewToBack(blur)
        blur.removeFromSuperview()
        activityIndicator.stopActivity()
    }
    
    func updateBackground() {
        var night: Bool = UserDefaultsManager.sharedInstance.getNight().boolValue()
        
        UIView.transitionWithView(background, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            if(night == true) {
                self.background.image = UIImage(named:"alarmsnight.png")
            } else {
                self.background.image = UIImage(named:"alarmsday.png")
            }
            }, completion: nil)
        
        //stopLoading()
    }
    
    // TODO: Hook up and test?
    // Need to generate the list of articles first somehow ?
    func checkCoreDataForArticles() {
        let results = CoreDataManager.sharedInstance.getObjectListForEntity("Articles")
        if(results.count > 0) {
            articles = results
            self.articleDisplayTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateArticleDisplay"), userInfo: nil, repeats: true)
        } else {
            
            if(self.articleDisplayTimer.valid == true) {
                self.articleDisplayTimer.invalidate()
            }
            
            newsView.hidden = false
        }
    }
    
    func updateArticleDisplay() {
        if(articles.count > 0) {
            newsView.hidden = false
            
            if(currentArticleIndex < (articles.count - 1)) {
                currentArticleIndex = currentArticleIndex + 1
            } else {
                currentArticleIndex = 0
            }
            
            let articleObject = articles[currentArticleIndex]
            
            var title = articleObject.valueForKey("title") as? String
            var creator = articleObject.valueForKey("creator") as? String
            var pubDate = articleObject.valueForKey("pubdate") as? NSDate
            var feedName = articleObject.valueForKey("feed") as? String
            var content = articleObject.valueForKey("content") as? String
            var link = articleObject.valueForKey("link") as? String
            var thumbnailUrl = articleObject.valueForKey("thumbnailurl") as? String
            
            var image: UIImage? = self.imageCache.objectForKey(title!) as? UIImage
            
            
            var q: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(q, {
                
                if(image != nil) {
                   self.thumbnailImageView.image = image!
                    
                } else {
                    
                    self.thumbnailImageView.image = nil
                    var image = (UIImage(named: "gm_unknown")!)
                    
                    if thumbnailUrl != "" {
                        /* Fetch the image from the server... */
                        
                        let url = NSURL(string: thumbnailUrl!)
                        if url != nil {
                            if let data = NSData(contentsOfURL: url!) {
                                image = (UIImage(data: data)!)
                            }
                        }
                    }
                }
                
                self.imageCache.setObject(image!, forKey: title!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // TODO: Animate this fade in/out
                    self.thumbnailImageView.image = image!
                    self.titleLabel.text = title
                    self.contentLabel.text = content
                    self.summaryLabel.text = feedName! + " / " + creator! + " / " + pubDate!.toFullDateString()
                });
            });
            
        } else {
            newsView.hidden = true
        }
    }
    
    func checkCoreDataForWeather() {
        let results = CoreDataManager.sharedInstance.getObjectListForEntity("Weather")
        if(results.count > 0) {
            weatherView.hidden = false
            
            let weather = results[0]
            cityLabel.text = weather.valueForKey("city") as? String
            var country = weather.valueForKey("country") as? String
            var condition = weather.valueForKey("condition") as? Int
            var night = weather.valueForKey("nighttime") as? Bool
            
            var unit = ""
            if(country == "US") {
                unit = " F°"
            } else {
                unit = " C°"
            }
            
            var doubleTemp = weather.valueForKey("temperature") as Double
            var temp =  String(format:"%.1f", doubleTemp) + unit
            temperatureLabel.text = temp
            weatherImageView.image = getImageForCondition(condition!, night!)
        } else {
            weatherView.hidden = true
        }
        
    }
    
    // MARK: - Notifications
    
    func receivedWeatherUpdate(notification: NSNotification) {
        //stopLoading()
    }
    
    func receivedNetworkError(notification: NSNotification) {
        //stopLoading()
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
    }
    
    // TODO: Handle Unknown location
    func receivedLocationUnknown(notification: NSNotification) {
        
    }
    
    // TODO: Better message to user if they disable it after installing
    func receivedLocationAuthorizeProblem(notification: NSNotification) {
        //stopLoading()
        SCLAlertView().showWarning("Location Services Disallowed",
            subTitle: "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning", closeButtonTitle: "Ok")
    }
    
    // MARK: - Actions
    
    @IBAction func refreshTapped(sender: UIBarButtonItem) {
        //startLoading()
        
    }
}
