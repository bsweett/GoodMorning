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
    
    // TODO: Depreacted replace with UIAlertController
    private let alert = UIAlertView()
    
    private var tapGesture : UIGestureRecognizer!
    
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
    @IBOutlet var clockTwoDates : UISegmentedControl!
    @IBOutlet var clockThreeDates : UISegmentedControl!
    @IBOutlet var clockFourDates : UISegmentedControl!
    
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
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blur.frame = view.frame
        blur.tag = 51
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("clockTapped:"))
        clockOneView.addGestureRecognizer(tapGesture)
        clockTwoView.addGestureRecognizer(tapGesture)
        clockThreeView.addGestureRecognizer(tapGesture)
        clockFourView.addGestureRecognizer(tapGesture)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name:"WeatherUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBackground", name: "NightCachedChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateAlarms:", name: "AlarmListUpdated", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDenied", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDisabled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name:"LocationUnknown", object: nil)
        
        updateBackground()
    }

    override func viewDidAppear(animated: Bool) {
        //var task: Task = Task()
        //alarmDict[1] = Alarm(task)
    }
    
    override func viewDidLayoutSubviews() {
        if(firstAppear == false) {
            startLoading()
            alarmManger.getAllAlarmsRequest()
            firstAppear = true
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
        let name4 : String = Array(taskDictionary.keys)[3]
        
        let task1 : Task = taskDictionary[name1]!
        let task2 : Task = taskDictionary[name2]!
        let task3 : Task = taskDictionary[name3]!
        let task4 : Task = taskDictionary[name4]!
        
        updateAlarmDisplay(task1, task2: task2, task3: task3, task4: task4)
    }
    
    private func updateAlarmDisplay(task1: Task, task2: Task, task3: Task, task4: Task) {
        self.clockOneName.text = task1.title
        self.clockOneTime.text = task1.displayAlertTime()
        self.clockOneDates.text = task1.daysOfWeekToDisplayString()
        self.clockOneSound.text = task1.displaySoundEnabledFlag()
        
        // TODO: Finish alarm configuration
        
        stopLoading()
    }
    
    func receivedWeatherUpdate(notification: NSNotification) {
        stopLoading()
    }
    
    func receivedNetworkError(notification: NSNotification) {
        stopLoading()
        alert.title = "Network Error"
        alert.message = "Please check your network connection"
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        stopLoading()
        alert.title = getUserInfoValueForKey(notification.userInfo, "reason")
        alert.message = getUserInfoValueForKey(notification.userInfo, "message")
        alert.addButtonWithTitle("Dismiss")
        alert.show()
    }
    
    // TODO: Handle Unknown location
    func receivedLocationUnknown(notification: NSNotification) {
        
    }
    
    // TODO: Better message to user if they disable it after installing
    func receivedLocationAuthorizeProblem(notification: NSNotification) {
        stopLoading()
        alert.title = "Location Services Disallowed"
        alert.message = "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning"
        alert.addButtonWithTitle("Ok")
        alert.show()
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
    
    func clockTapped(sender: UIGestureRecognizer) {
        let view: UIView = sender.view!
        
        if(view == clockOneView) {
            println("tapped clock")
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

