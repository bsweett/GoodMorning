//
//  LocationManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-18.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import CoreLocation

private let _locationManagerSharedInstance = LocationManager()

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    var timer: NSTimer! = NSTimer()
    
    class var sharedInstance : LocationManager {
        return _locationManagerSharedInstance
    }
    
    func startLocationTask() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if ( ios8() ) {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        // for now every 60 seconds. When its working make it run every 5 minutes
         timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func stopLocationTask() {
        timer.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
    }
    
    private func ios8() -> Bool {
        if ( NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 ) {
            return false
        } else {
            return true
        }
    }
    
    func update() {
        locationManager.startUpdatingLocation()
    }
    
    // Location delegate methods
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        
        if (location.horizontalAccuracy > 0) {
            locationManager.stopUpdatingLocation()
            
            println("updated location")
            
            var result: Int = WeatherManager.sharedInstance.getWeatherForLocation(location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            if(result != 0) {
                NSNotificationCenter.defaultCenter().postNotificationName("WeatherError", object: nil)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        NSNotificationCenter.defaultCenter().postNotificationName("LocationError", object: nil)
    }
    
}