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
    let weatherManager: WeatherManager = WeatherManager()
    
    class var sharedInstance : LocationManager {
        return _locationManagerSharedInstance
    }
    
    func update() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if ( ios8() ) {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    
    private func ios8() -> Bool {
        if ( NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 ) {
            return false
        } else {
            return true
        }
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
    }
    
    func cacheLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        
    }
    
}