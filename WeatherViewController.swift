//
//  WeatherViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import QuartzCore

class WeatherViewController : UIViewController {
    
    var timer: NSTimer! = NSTimer()
    
    @IBOutlet var loadingIndicator : UIActivityIndicatorView! = nil
    @IBOutlet var loading : UILabel!
    @IBOutlet var nextViewButton: UIBarButtonItem!
    @IBOutlet var previousViewButton: UIBarButtonItem!
    @IBOutlet var background: UIImageView!
    
    @IBOutlet var currentTemp : UILabel!
    @IBOutlet var currentCity : UILabel!
    @IBOutlet var currentIcon: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        LocationManager.sharedInstance.update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationError:", name:"LocationError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherError:", name:"WeatherError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name:"WeatherUpdated", object: nil)
        
        
        //self.loadingIndicator.startAnimating()
    }

    override func viewDidAppear(animated: Bool) {
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateBackgroundAndWeather(current: Weather, forecast: [Weather!]) {
        var night = current.nighttime
        
        UIView.transitionWithView(background, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            if(night == true) {
                self.background.image = UIImage(named:"weathernight.png")
            } else {
                self.background.image = UIImage(named:"weatherday.png")
            }
        }, completion: nil)
        
        UIView.transitionWithView(currentIcon, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            if(night == true) {
                self.setImageViewForNightCondition(current.condition, imageView: self.currentIcon)
            } else {
                self.setImageViewForDayCondition(current.condition, imageView: self.currentIcon)
            }
        }, completion: nil)
        
        currentCity.text = current.city
        
        if(current.country == "US") {
            currentTemp.text = current.temperature.description + " F°"
        } else {
            currentTemp.text = current.temperature.description + " C°"
        }
        
        //TODO Update weather items
    }
    
    func setImageViewForNightCondition(condidtion: Int, imageView: UIImageView) {
        
    }
    
    func setImageViewForDayCondition(condidtion: Int, imageView: UIImageView) {
        
    }
    
    func receivedWeatherUpdate(notification: NSNotification) {
        let userInfo:Dictionary<String,Weather> = notification.userInfo as Dictionary<String,Weather>
        let current: Weather = userInfo["current"]!
        let forecast1 = userInfo["forecast1"]
        let forecast2 = userInfo["forecast2"]
        let forecast3 = userInfo["forecast3"]
        let forecast4 = userInfo["forecast4"]
        
        let forecastArray: [Weather!] = [forecast1, forecast2, forecast3, forecast4]
        
        self.updateBackgroundAndWeather(current, forecast: forecastArray)
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