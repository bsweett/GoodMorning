//
//  AlarmsViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class AlarmsViewController : UIViewController {
    
    var timer: NSTimer! = NSTimer()
    
    @IBOutlet var loadingIndicator : UIActivityIndicatorView! = nil
    @IBOutlet var loading : UILabel!
    @IBOutlet var nextViewButton: UIBarButtonItem!
    @IBOutlet var previousViewButton: UIBarButtonItem!
    @IBOutlet var background: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        LocationManager.sharedInstance.update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationError:", name:"LocationError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherError:", name:"WeatherError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name:"WeatherUpdated", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {

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
    
    func receivedWeatherError(notification: NSNotification){
        self.loading.text = "Response from Weather API was invalid"
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("clearError"), userInfo: nil, repeats: false)
    }
    
    func receivedLocationError(notification: NSNotification){
        self.loading.text = "Cannot find your location"
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("clearError"), userInfo: nil, repeats: false)
    }
    
    func clearError() {
        self.loading.text = ""
        timer.invalidate()
        timer = nil
    }
    
     @IBAction func nextButtonAction(sender:UIBarButtonItem!) {
        if let parent = self.parentViewController as? PageViewController {
            parent.setViewControllers([parent.getWeather()!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion:nil)
        }
    }
    
     @IBAction func previousButtonAction(sender:UIBarButtonItem!) {
        if let parent = self.parentViewController as? PageViewController {
            parent.setViewControllers([parent.getTasks()!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true,completion:nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
}

