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
import DTIActivityIndicator

class WeatherViewController : UIViewController {
    
    private var timer: NSTimer! = NSTimer()
    private var firstAppear: Bool = false
    
    @IBOutlet weak var activityIndicator: DTIActivityIndicatorView!
    @IBOutlet weak var forcastBlock: UIView!
    @IBOutlet var background: UIImageView!
    
    @IBOutlet var currentTemp : UILabel!
    @IBOutlet var currentCity : UILabel!
    @IBOutlet var currentIcon: UIImageView!
    
    @IBOutlet var forcastTemp1 : UILabel!
    @IBOutlet var forcastTime1 : UILabel!
    @IBOutlet var forcastIcon1: UIImageView!
    
    @IBOutlet var forcastTemp2 : UILabel!
    @IBOutlet var forcastTime2 : UILabel!
    @IBOutlet var forcastIcon2: UIImageView!
    
    @IBOutlet var forcastTemp3 : UILabel!
    @IBOutlet var forcastTime3 : UILabel!
    @IBOutlet var forcastIcon3: UIImageView!
    
    @IBOutlet var forcastTemp4 : UILabel!
    @IBOutlet var forcastTime4 : UILabel!
    @IBOutlet var forcastIcon4: UIImageView!
    
    private var blur: UIVisualEffectView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundBlockCorners()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let lightBlur = UIVisualEffectView(effect: blurEffect)
        lightBlur.frame = self.view.bounds //view is self.view in a UIViewController
        self.background.addSubview(lightBlur)
        
        blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blur.frame = view.frame
        blur.tag = 50
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(firstAppear == false) {
            startLoading()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bringSubviewToFront(activityIndicator)
        self.parentViewController?.title  = weatherTitle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name: kNetworkError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedInternalServerError:", name: kInternalServerError, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name: kWeatherUpdated, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name: kLocationDenied, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationAuthorizeProblem:", name: kLocationDisabled, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationUnknown:", name: kLocationUnknown, object: nil)
        
        if(firstAppear == false) {
            LocationManager.sharedInstance.update()
            firstAppear = true
        }
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func roundBlockCorners() {
        
        forcastBlock.layer.cornerRadius = radius
        forcastBlock.clipsToBounds = true
        
    }
    
    func startLoading() {
        self.view.addSubview(blur)
        activityIndicator.startActivity()
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    func stopLoading() {
        blur.removeFromSuperview()
        activityIndicator.stopActivity()
    }
    
    // Fix me some slow ui issues.. try without animatation
    private func updateBackgroundAndWeather(current: Weather, forecast: [Weather!]) {
        var unit = ""
        
        if(current.country == "US") {
            unit = " F°"
        } else {
            unit = " C°"
        }
        
        // Update Current
        
        if(current.nighttime == true) {
            self.background.image = UIImage(named:"weathernight.png")
        } else {
            self.background.image = UIImage(named:"weatherday.png")
        }
        
        self.currentIcon.image = getImageForCondition(current.condition, current.nighttime)
        
        currentCity.text = current.city
        currentTemp.text = current.temperature.description + unit
        currentTemp.text = current.temperature.description + unit
        
        //Update Forecast
        
        self.forcastIcon1.image = getImageForCondition(forecast[0].condition, forecast[0].nighttime)
        self.forcastIcon2.image = getImageForCondition(forecast[1].condition, forecast[1].nighttime)
        self.forcastIcon3.image = getImageForCondition(forecast[2].condition, forecast[2].nighttime)
        self.forcastIcon4.image = getImageForCondition(forecast[3].condition, forecast[3].nighttime)
        
        forcastTemp1.text = forecast[0].temperature.description + unit
        forcastTemp2.text = forecast[1].temperature.description + unit
        forcastTemp3.text = forecast[2].temperature.description + unit
        forcastTemp4.text = forecast[3].temperature.description + unit
        
        forcastTime1.text = forecast[0].time
        forcastTime2.text = forecast[1].time
        forcastTime3.text = forecast[2].time
        forcastTime4.text = forecast[3].time
        
        stopLoading()
    }
    
    @IBAction func refreshTapped(sender: UIBarButtonItem) {
        startLoading()
        LocationManager.sharedInstance.update()
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
        SCLAlertView().showWarning(internalErrTitle,
            subTitle:  reason + " - " + message, closeButtonTitle: dismissButTitle)
    }
    
    // TODO: Better message to user if they disable it after installing
    func receivedLocationAuthorizeProblem(notification: NSNotification) {
        stopLoading()
        SCLAlertView().showWarning(locationDisTitle,
            subTitle: "Because you have disallowed location services you are required to enter your country and city in order to use GoodMorning", closeButtonTitle: okButTitle)
    }
    
}