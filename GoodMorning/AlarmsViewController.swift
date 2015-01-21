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

class AlarmsViewController : UIViewController {
    
    private var timer: NSTimer! = NSTimer()
    private var firstAppear: Bool = false
    
    private let alert = UIAlertView()
    
    private var tapGesture : UIGestureRecognizer!
    
    @IBOutlet var loadingIndicator : UIActivityIndicatorView! = nil
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
    
    private var alarmDict: Dictionary<NSInteger, Alarm> = [:]
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //LocationManager.sharedInstance.update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name:"InternalServerError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name:"WeatherUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDenied", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name:"LocationDisabled", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name:"LocationUnknown", object: nil)
        
        self.roundClockBackgrounds()
        LocationManager.sharedInstance.update()
    }

    override func viewDidAppear(animated: Bool) {
        if(firstAppear == false) {
            LocationManager.sharedInstance.update()
            firstAppear == true
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: Selector("clockTapped:"))
        clockOneView.addGestureRecognizer(tapGesture)
        clockTwoView.addGestureRecognizer(tapGesture)
        clockThreeView.addGestureRecognizer(tapGesture)
        clockFourView.addGestureRecognizer(tapGesture)
        
        //var task: Task = Task()
        //alarmDict[1] = Alarm(task)
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        clockOneView.removeGestureRecognizer(tapGesture)
        clockTwoView.removeGestureRecognizer(tapGesture)
        clockThreeView.removeGestureRecognizer(tapGesture)
        clockFourView.removeGestureRecognizer(tapGesture)
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
    
    private func updateBackground(current: Weather) {
        var night = current.nighttime
        
        UIView.transitionWithView(background, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            if(night == true) {
                self.background.image = UIImage(named:"alarmsnight.png")
            } else {
                self.background.image = UIImage(named:"alarmsday.png")
            }
        }, completion: nil)
    }
    
    func receivedWeatherUpdate(notification: NSNotification) {
        let userInfo:Dictionary<String,Weather> = notification.userInfo as Dictionary<String,Weather>
        let current: Weather = userInfo["current"]!

        self.updateBackground(current)
    }
    
    func receivedNetworkError(notification: NSNotification) {
        alert.title = "Network Error"
        alert.message = "Please check your network connection"
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func receivedInternalServerError(notification: NSNotification) {
        alert.title = getUserInfoValueForKey(notification.userInfo, "reason")
        alert.message = getUserInfoValueForKey(notification.userInfo, "message")
        alert.addButtonWithTitle("Dismiss")
        alert.show()
    }
    
    // TODO: Better message to user if they disable it after installing
    func receivedLocationAuthorizeProblem(notification: NSNotification) {
        alert.title = "Location Services Disallowed"
        alert.message = "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning"
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func clearError() {
        self.loading.text = ""
    }
    
    /*
     @IBAction func nextButtonAction(sender:UIBarButtonItem!) {
        if let parent = self.parentViewController as? PageViewController {
            parent.setViewControllers([parent.getWeather()!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion:nil)
        }
    }
    
     @IBAction func previousButtonAction(sender:UIBarButtonItem!) {
        if let parent = self.parentViewController as? PageViewController {
            parent.setViewControllers([parent.getTasks()!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true,completion:nil)
        }
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        firstAppear = false
        // Dispose of any resources that can be recreated.
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

