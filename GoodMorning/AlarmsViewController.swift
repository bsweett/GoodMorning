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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedLocationError:", name:"LocationError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedWeatherError", name:"WeatherError", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        
        // TODO: Compare with sunset time from weather api
        if (hour > 12) {
            
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

