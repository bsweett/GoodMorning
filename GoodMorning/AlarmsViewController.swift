//
//  AlarmsViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import DTIActivityIndicator

class AlarmsViewController : UIViewController {
    
    private var timer: NSTimer! = NSTimer()
    private var firstAppear: Bool = false
    
    private var tapGesture : UITapGestureRecognizer!
    
    @IBOutlet weak var activityIndicator: DTIActivityIndicatorView!
    @IBOutlet var loading : UILabel!
    @IBOutlet var background: UIImageView!
    
    @IBOutlet var clockOneView : UIView!
    @IBOutlet var clockTwoView : UIView!
    @IBOutlet var clockThreeView : UIView!
    @IBOutlet var clockFourView : UIView!
    
    @IBOutlet var clockOneName : UILabel!
    @IBOutlet var clockTwoName : UILabel!
    @IBOutlet var clockThreeName : UILabel!
    @IBOutlet var clockFourName : UILabel!
    
    @IBOutlet var clockOneTime : UILabel!
    @IBOutlet var clockTwoTime : UILabel!
    @IBOutlet var clockThreeTime : UILabel!
    @IBOutlet var clockFourTime : UILabel!
    
    @IBOutlet var clockOneDates : UILabel!
    @IBOutlet var clockTwoDates : UILabel!
    @IBOutlet var clockThreeDates : UILabel!
    @IBOutlet var clockFourDates : UILabel!
    
    @IBOutlet var clockOneSound : UILabel!
    @IBOutlet var clockTwoSound : UILabel!
    @IBOutlet var clockThreeSound : UILabel!
    @IBOutlet var clockFourSound : UILabel!
    
    @IBOutlet var clockOneSwitch : UISwitch!
    @IBOutlet var clockTwoSwitch : UISwitch!
    @IBOutlet var clockThreeSwitch : UISwitch!
    @IBOutlet var clockFourSwitch : UISwitch!
    
    private var alarmDict: Dictionary<String, Task> = [:]

    private var blur: UIVisualEffectView!
    private var darkBlur: UIVisualEffectView!
    
    private var alarmManger: AlarmsManager!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        alarmManger = AlarmsManager()
        //LocationManager.sharedInstance.update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.roundClockBackgrounds()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        darkBlur = UIVisualEffectView(effect: blurEffect)
        self.darkBlur.frame = self.view.bounds //view is self.view in a UIViewController
        self.background.addSubview(self.darkBlur)
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = view.frame
        blur.tag = 51
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name:"WeatherUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBackground", name: "NightCachedChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAlarms:", name: "AlarmListUpdated", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDenied", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDisabled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name:"LocationUnknown", object: nil)
        
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("clockTapped:"))
        tapGesture.numberOfTapsRequired = 2
        
        self.parentViewController?.title = "Alarms"
        

        
        updateBackground()
        
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        clockOneView.addGestureRecognizer(tapGesture)
        clockTwoView.addGestureRecognizer(tapGesture)
        clockThreeView.addGestureRecognizer(tapGesture)
        clockFourView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if(firstAppear == false) {
            firstAppear = true
            
            if(!Reachability.isConnectedToNetwork()) {
                startLoading()
                stopLoading()
                SCLAlertView().showNotice("No Network Connection",
                    subTitle: "You don't appear to be connected to the Internet. Please check your connection.",
                    duration: 6)
            } else {
                startLoading()
                alarmManger.getAllAlarmsRequest()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        clockOneView.removeGestureRecognizer(tapGesture)
        clockTwoView.removeGestureRecognizer(tapGesture)
        clockThreeView.removeGestureRecognizer(tapGesture)
        clockFourView.removeGestureRecognizer(tapGesture)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func roundClockBackgrounds() {
        
        clockOneView.layer.cornerRadius = radius
        clockTwoView.layer.cornerRadius = radius
        clockThreeView.layer.cornerRadius = radius
        clockFourView.layer.cornerRadius = radius
        
        clockOneView.clipsToBounds = true
        clockTwoView.clipsToBounds = true
        clockThreeView.clipsToBounds = true
        clockFourView.clipsToBounds = true
        
    }
    
    func startLoading() {
        self.view.addSubview(blur)
        self.view.bringSubviewToFront(blur)
        activityIndicator.startActivity()
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    func stopLoading() {
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
        
        stopLoading()
    }
    
    func updateAlarms(notification: NSNotification) {
        let taskDictionary = notification.userInfo as Dictionary<String,Task>
        self.alarmDict = taskDictionary
        
        let name1 : String = Array(taskDictionary.keys)[0]
        let name2 : String = Array(taskDictionary.keys)[1]
        let name3 : String = Array(taskDictionary.keys)[2]
        //let name4 : String = Array(taskDictionary.keys)[3]
        
        let task1 : Task = taskDictionary[name1]!
        let task2 : Task = taskDictionary[name2]!
        let task3 : Task = taskDictionary[name3]!
        let task4 : Task = taskDictionary[name3]!
        
        updateAlarmDisplay(task1, task2: task2, task3: task3, task4: task4)
    }
    
    private func updateAlarmDisplay(task1: Task, task2: Task, task3: Task, task4: Task) {
        self.clockOneName.text = task1.title
        self.clockOneTime.text = task1.displayAlertTime()
        self.clockOneDates.text = task1.daysOfWeekToDisplayString()
        self.clockOneSound.text = task1.displaySoundEnabledFlag()
        
        self.clockTwoName.text = task2.title
        self.clockTwoTime.text = task2.displayAlertTime()
        self.clockTwoDates.text = task2.daysOfWeekToDisplayString()
        self.clockTwoSound.text = task2.displaySoundEnabledFlag()
        
        // TODO: Finish alarm configuration
        self.clockThreeName.text = task3.title
        self.clockThreeTime.text = task3.displayAlertTime()
        self.clockThreeDates.text = task3.daysOfWeekToDisplayString()
        self.clockThreeSound.text = task3.displaySoundEnabledFlag()
        
        /*
        self.clockFourName.text = task4.title
        self.clockFourTime.text = task4.displayAlertTime()
        self.clockFourDates.text = task4.daysOfWeekToDisplayString()
        self.clockFourSound.text = task4.displaySoundEnabledFlag()*/
        
        stopLoading()
    }
    
    func receivedWeatherUpdate(notification: NSNotification) {
        stopLoading()
    }
    
    func receivedNetworkError(notification: NSNotification) {
        stopLoading()
        /*SCLAlertView().showError("Network Error",
            subTitle: "Oops something went wrong",
            closeButtonTitle: "Dismiss")*/
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        stopLoading()
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
        stopLoading()
        SCLAlertView().showWarning("Location Services Disallowed",
            subTitle: "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning", closeButtonTitle: "Ok")
    }
    
    // MARK: - Actions
    
    @IBAction func refreshTapped(sender: UIBarButtonItem) {
        startLoading()
        alarmManger.getAllAlarmsRequest()
    }
    
    @IBAction func clockSwitchFlipped(sender: UISwitch) {
        
        if(sender.on) {
            turnOnClockView(sender)
        } else {
            turnOffClockView(sender)
        }
        
    }
    
    func turnOnClockView(uiswitch: UISwitch) {
        
        if(uiswitch == clockOneSwitch) {

            clockOneView.alpha = 0.8
            clockOneView.addGestureRecognizer(tapGesture)
            
        } else if (uiswitch == clockTwoSwitch) {
            
            clockTwoView.alpha = 0.8
            clockTwoView.addGestureRecognizer(tapGesture)

        } else if (uiswitch == clockThreeSwitch) {
            
            clockThreeView.alpha = 0.8
            clockThreeView.addGestureRecognizer(tapGesture)
            
        } else if (uiswitch == clockFourSwitch) {
            
            clockFourView.alpha = 0.8
            clockFourView.addGestureRecognizer(tapGesture)
            
        }
        
    }
    
    func turnOffClockView(uiswitch: UISwitch) {
        
        if(uiswitch == clockOneSwitch) {
            
            clockOneView.alpha = 0.4
            clockOneView.removeGestureRecognizer(tapGesture)
            
        } else if (uiswitch == clockTwoSwitch) {
            
            clockTwoView.alpha = 0.4
            clockTwoView.removeGestureRecognizer(tapGesture)
            
        } else if (uiswitch == clockThreeSwitch) {
            
            clockThreeView.alpha = 0.4
            clockThreeView.removeGestureRecognizer(tapGesture)
            
        } else if (uiswitch == clockFourSwitch) {
            
            clockFourView.alpha = 0.4
            clockFourView.removeGestureRecognizer(tapGesture)
            
        }
       
    }
    
    func clockTapped(sender: UITapGestureRecognizer) {
        let view: UIView = sender.view!
        let parent: PageViewController = self.parentViewController as PageViewController
        
        println("double tap")
        
        if(view == clockOneView) {
            parent.displayTasksView()
        } else if (view == clockTwoView) {
            
        } else if (view == clockThreeView) {
            
        } else if (view == clockFourView) {
            
        }
        
        // TODO: edit popover or full view?
        
        //performSegueWithIdentifier("EditAlarm", sender: self)
    }
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        // Pass alarm object to be editted
    
    }
    
    
}

