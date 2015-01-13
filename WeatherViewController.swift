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
    var firstAppear: Bool = false
    
    @IBOutlet var loadingIndicator : UIActivityIndicatorView! = nil
    @IBOutlet var loading : UILabel!
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingIndicator.hidesWhenStopped = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationError:", name:"LocationError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedNetworkError:", name:"NetworkError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherUpdate:", name:"WeatherUpdated", object: nil)
        
    }

    override func viewDidAppear(animated: Bool) {
        if(firstAppear == false) {
            LocationManager.sharedInstance.update()
            firstAppear = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.loadingIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        firstAppear = false
    }
    
    private func updateBackgroundAndWeather(current: Weather, forecast: [Weather!]) {
        var unit = ""
        
        if(current.country == "US") {
            unit = " F°"
        } else {
            unit = " C°"
        }
        
        // Update Current
        
        UIView.transitionWithView(background, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            if(current.nighttime == true) {
                self.background.image = UIImage(named:"weathernight.png")
            } else {
                self.background.image = UIImage(named:"weatherday.png")
            }
        }, completion: nil)
        
        UIView.transitionWithView(currentIcon, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.setImageViewForCondition(current.condition,night: current.nighttime, imageView: self.currentIcon)
        }, completion: nil)
        
        currentCity.text = current.city
        currentTemp.text = current.temperature.description + unit
        currentTemp.text = current.temperature.description + unit
        
        //Update Forecast
        
        UIView.transitionWithView(forcastIcon1, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.setImageViewForCondition(forecast[0].condition, night: forecast[0].nighttime, imageView: self.forcastIcon1)
        }, completion: nil)
        
        UIView.transitionWithView(forcastIcon2, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.setImageViewForCondition(forecast[1].condition, night: forecast[1].nighttime, imageView: self.forcastIcon2)
        }, completion: nil)
        
        UIView.transitionWithView(forcastIcon3, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.setImageViewForCondition(forecast[2].condition, night: forecast[2].nighttime, imageView: self.forcastIcon3)
        }, completion: nil)
        
        UIView.transitionWithView(forcastIcon4, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.setImageViewForCondition(forecast[3].condition, night: forecast[3].nighttime, imageView: self.forcastIcon4)
        }, completion: nil)
        
        
        forcastTemp1.text = forecast[0].temperature.description + unit
        forcastTemp2.text = forecast[1].temperature.description + unit
        forcastTemp3.text = forecast[2].temperature.description + unit
        forcastTemp4.text = forecast[3].temperature.description + unit
        
        forcastTime1.text = forecast[0].time
        forcastTime2.text = forecast[1].time
        forcastTime3.text = forecast[2].time
        forcastTime4.text = forecast[3].time
        
        self.loadingIndicator.stopAnimating()
    }
    
    func setImageViewForCondition(condition: Int, night: Bool, imageView: UIImageView) {
        
        var imageName = ""
        
        if(condition < 300) {
            imageName = "thunder"
        } else if (condition < 500) {
            imageName = "drizzle"
        } else if (condition < 600) {
            imageName = "rain"
        } else if (condition < 602) {
            imageName = "snow"
        } else if (condition < 612) {
            imageName = "heavysnow"
        } else if (condition < 700) {
            imageName = "snowandrain"
        } else if (condition < 771) {
            imageName = "fog"
        } else if (condition < 800) {
            imageName = "tornado"
        } else if (condition == 800) {
            imageName = "clear"
        } else if (condition < 804) {
            imageName = "scattered"
        } else if (condition == 804) {
            imageName = "overcast"
        } else if (condition >= 900 && condition <= 902 || condition == 905) {
            imageName = "extreme"
        } else if (condition == 903) {
            imageName = "cold"
        } else if (condition == 904) {
            imageName = "heat"
        } else if (condition > 950 && condition <= 955) {
            imageName = "calm"
        } else if (condition > 955 && condition <= 958) {
            imageName = "windy"
        } else if (condition > 958 && condition < 1000) {
            imageName = "storm"
        } else {
            imageName = "unknown"
        }
        
        if(imageName != "unknown") {
            if(night == true) {
                imageName = "n_" + imageName
            } else {
                imageName = "d_" + imageName
            }
        }
        
        imageView.image = UIImage(named:(imageName + ".png"))
    }
 
    
    func receivedWeatherUpdate(notification: NSNotification) {
        
        self.loadingIndicator.startAnimating()
        
        let userInfo:Dictionary<String,Weather> = notification.userInfo as Dictionary<String,Weather>
        let current: Weather = userInfo["current"]!
        let forecast1 = userInfo["forecast1"]
        let forecast2 = userInfo["forecast2"]
        let forecast3 = userInfo["forecast3"]
        let forecast4 = userInfo["forecast4"]
        
        let forecastArray: [Weather!] = [forecast1, forecast2, forecast3, forecast4]
        
        self.updateBackgroundAndWeather(current, forecast: forecastArray)
    }

    func receivedNetworkError(notification: NSNotification){
        self.loading.text = "Network Error"
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("clearError"), userInfo: nil, repeats: false)
    }
    
    func receivedLocationError(notification: NSNotification){
        self.loading.text = "Cannot find your location"
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("clearError"), userInfo: nil, repeats: false)
    }
    
    func clearError() {
        self.loading.text = ""
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