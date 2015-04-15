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

class HubViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    @IBOutlet weak var alarmsTableView: UITableView!
    
    private var taskManager: TaskManager!
    private var alarms: [Task]!
    
    private var articles: [NSManagedObject]!
    private var articleDisplayTimer: NSTimer!
    private var currentArticleIndex: Int!
    var imageCache: NSCache!
    
    var weatherString = ""
    var speakWhileVisible = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarms = []
        taskManager = TaskManager()
        articles = [NSManagedObject]()
        currentArticleIndex = -1
        imageCache = NSCache()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        alarmsTableView.registerNib(UINib(nibName: "AlarmViewCell", bundle: nil), forCellReuseIdentifier: "alarmCell")
        alarmsTableView.dataSource = self
        alarmsTableView.delegate = self
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        darkBlur = UIVisualEffectView(effect: blurEffect)
        self.darkBlur.frame = self.view.bounds //view is self.view in a UIViewController
        self.background.addSubview(self.darkBlur)
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = view.frame
        blur.tag = 51
        
        LocationManager.sharedInstance.update()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name: kNetworkError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInternalServerError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name: kWeatherUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBackground", name: kNightCachedChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAlarms:", name: kAlarmListUpdated, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name: kLocationDenied, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name: kLocationDisabled, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name: kLocationUnknown, object: nil)
        
        self.parentViewController?.title = "Hub"
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(firstAppear == false) {
            firstAppear = true
            
            startLoading()
            stopLoading()
            
            refreshContent()
        }
        
        speakWhileVisible = true
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
        speakWhileVisible = false
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
    
    func refreshContent() {
        if(!Reachability.isConnectedToNetwork()) {
            
            SCLAlertView().showNotice(internetErrTitle,
                subTitle: internetErrMessage,
                duration: 6)
            
            checkCoreDataForAlarms()
        } else {
            taskManager.getAllAlarmsRequest()
        }
        
        updateBackground()
        checkCoreDataForWeather()
        checkCoreDataForArticles()
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
    }
    
    // MARK: - Core Data Hub Building
    
    func checkCoreDataForArticles() {
        let results = CoreDataManager.sharedInstance.getObjectListForEntity("Articles")
        if(results.count > 0) {
            articles = shuffle(results)
            updateArticleDisplay()
            self.articleDisplayTimer = NSTimer.scheduledTimerWithTimeInterval(45, target: self, selector: Selector("updateArticleDisplay"), userInfo: nil, repeats: true)
        } else {
            
            if(articleDisplayTimer != nil) {
                if(self.articleDisplayTimer.valid == true) {
                    self.articleDisplayTimer.invalidate()
                }
                
                newsView.hidden = false
            } else {
                newsView.hidden = true
            }
        }
    }
    
    // Shuffle articles
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let count = countElements(list)
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
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
            
            if(image != nil) {
                self.thumbnailImageView.image = image!
                
            } else {
                
                self.thumbnailImageView.image = nil
                var image = UIImage(named: "gm_unknown")
                
                if thumbnailUrl != "" {
                    let url = NSURL(string: thumbnailUrl!)
                    if url != nil {
                        if let data = NSData(contentsOfURL: url!) {
                            image = (UIImage(data: data)!)
                            if(image != nil) {
                                self.imageCache.setObject(image!, forKey: title!)
                            }
                            
                            self.thumbnailImageView.image = image!
                        }
                    }
                }
            }
            
            
            self.titleLabel.text = title
            self.contentLabel.text = content
            self.summaryLabel.text = feedName! + " / " + creator! + " / " + pubDate!.toFullDateString()
            
            if(speakWhileVisible) {
                var speech = TextToSpeech()
                
                if(weatherString != "") {
                    speech.speakWithPostAndPreDelay(weatherString, preLength: 2.0, postLength: 1.0)
                    weatherString = ""
                }
                speech.speakStringsWithPause(title!, words2: "published by " + feedName! + " on " + pubDate!.toShortDateString() + " at " + pubDate!.toShortTimeString(), pauseLength: 0.3)
            }
            
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
            var speakUnit = ""
            if(country == "US") {
                unit = " F°"
                speakUnit = "fahrenheit"
            } else {
                unit = " C°"
                speakUnit = "celsius"
            }
            
            var doubleTemp = weather.valueForKey("temperature") as Double
            var temp =  String(format:"%.f", doubleTemp)
            temperatureLabel.text = temp + unit
            weatherImageView.image = getImageForCondition(condition!, night!)
            
            weatherString = ("It is " + temp + " degrees " + speakUnit + " outside")
            
        } else {
            weatherView.hidden = true
        }
        
    }
    
    func checkCoreDataForAlarms() {
        let results = CoreDataManager.sharedInstance.getObjectListForEntity("Alarms")
        if(results.count > 0) {
            self.alarms = []
            for result in results {
                
                var id = result.valueForKey("id") as? String
                var title = result.valueForKey("title") as? String
                var typeString = result.valueForKey("type") as? String
                var time = result.valueForKey("time") as? String
                var soundfilename = result.valueForKey("soundfilename") as? String
                var creation = result.valueForKey("creation") as? NSDate
                var nextdate = result.valueForKey("nextdate") as? NSDate
                var mon = result.valueForKey("mon") as? Bool
                var tue = result.valueForKey("tue") as? Bool
                var wed = result.valueForKey("wed") as? Bool
                var thu = result.valueForKey("thu") as? Bool
                var fri = result.valueForKey("fri") as? Bool
                var sat = result.valueForKey("sat") as? Bool
                var sun = result.valueForKey("sun") as? Bool
                
                var type: TaskType = TaskType.typeFromString(typeString!)
                
                var alarm = Task(id: id!, title: title!, creation: creation!, nextAlert: nextdate!, type: type, link: DeepLinkType.NONE, alertTime: time!, soundFileName: soundfilename!, notes: "")
                
                self.alarms.append(alarm)
            }
        }
        
        self.alarmsTableView.reloadData()
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AlarmViewCell = tableView.dequeueReusableCellWithIdentifier("alarmCell") as AlarmViewCell!
        
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        cell.setAlarmTask(alarms[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (self.alarms.count > 0) {
            alarmsView.hidden = false
            return 1;
        }
        
        alarmsView.hidden = true
        
        return 0;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
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
        let cell = tableView.cellForRowAtIndexPath(indexPath) as AlarmViewCell!
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var task = cell.getAlarm()
    }
    
    
    // MARK: - Notifications
    
    func updateAlarms(notification: NSNotification) {
        let alarmList: Dictionary<String, Task>! = notification.userInfo as Dictionary<String, Task>!
        self.alarms = []
        
        for alarm in alarmList.values {
            alarms.append(alarm)
        }
        
        self.alarmsTableView.reloadData()
    }
    
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
        let reason = getUserInfoValueForKey(notification.userInfo, "reason")
        let message = getUserInfoValueForKey(notification.userInfo, "message")
        SCLAlertView().showWarning(internalErrTitle,
            subTitle:  reason + " - " + message, closeButtonTitle: dismissButTitle)
    }
    
    // TODO: Handle Unknown location
    func receivedLocationUnknown(notification: NSNotification) {
        
    }
    
    // TODO: Better message to user if they disable it after installing
    func receivedLocationAuthorizeProblem(notification: NSNotification) {
        SCLAlertView().showWarning(locationDisTitle,
            subTitle: "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning", closeButtonTitle: okButTitle)
    }
    
    // MARK: - Actions
    
    @IBAction func refreshTapped(sender: UIBarButtonItem) {
        refreshContent()
    }
    
}
