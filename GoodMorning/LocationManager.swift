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
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func update() {
        
        if ( ios8() ) {
            
            if(CLLocationManager.locationServicesEnabled() == true) {
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                return
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("LocationDisabled", object: nil)
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    
    // Location delegate methods
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        
        if (location.horizontalAccuracy > 0) {
            self.stopUpdate()
            
            println("updated location")
            
            self.weatherManager.getWeatherForLocation(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        if error.code == CLError.LocationUnknown.rawValue {
            NSNotificationCenter.defaultCenter().postNotificationName("LocationUnknown", object: nil)
            
        } else if error.code == CLError.Denied.rawValue {
            NSNotificationCenter.defaultCenter().postNotificationName("LocationDenied", object: nil)
            
        } else {
            println("Unknown location error: ", error)
            
        }

    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if(status == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
            
            // Might not need this if we just try to update all the time and have the error handler catch the denied option
        } else if(status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted) {
            NSNotificationCenter.defaultCenter().postNotificationName("LocationDenied", object: nil)
            
        } else if(status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways) {
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
}