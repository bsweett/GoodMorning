//
//  LocationManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-18.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    let weatherManager: WeatherManager = WeatherManager()
    var failCount: Int = 0
    
    class var sharedInstance : LocationManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : LocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationManager()
        }
        return Static.instance!
    }
    
    func update() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if ( ios8() ) {
            
            if(CLLocationManager.locationServicesEnabled() == true) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                // Not enabled manual set somehow
            }
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    
    func resetFailureCount() {
        self.failCount = 0
    }
    
    // Location delegate methods
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        
        if (location.horizontalAccuracy > 0) {
            locationManager.stopUpdatingLocation()
            
            println("updated location")
            
            self.weatherManager.getWeatherForLocation(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        NSNotificationCenter.defaultCenter().postNotificationName("LocationError", object: nil)
        if(failCount >= 3) {
            self.stopUpdate()
        }
        failCount += 1
    }
    
}