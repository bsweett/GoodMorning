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
    
    /**
    Initializes the location manager
    
    :returns: nil
    */
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /**
    Asks the location manager to update the current location if it is supported
    */
    func update() {
        
        if ( ios8() ) {
            
            if(CLLocationManager.locationServicesEnabled() == true) {
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
                return
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLocationDisabled, object: nil)
    }
    
    /**
    Stops updating the location
    */
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    
    
    //MARK: - Location delegate methods
    
    /**
    Tells the app that new location data is available. Sends the new location data to the weather manager
    
    :param: manager   The location manager object that generated the update event.
    :param: locations An array of CLLocation objects containing the location data.
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        
        if (location.horizontalAccuracy > 0) {
            self.stopUpdate()
            self.weatherManager.getWeatherForLocation(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    /**
    Tells the app that the location manager was unable to retrieve a location value.
    
    :param: manager The location manager object that was unable to retrieve the location.
    :param: error   The error object containing the reason the location or heading could not be retrieved.
    */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        if error.code == CLError.LocationUnknown.rawValue {
            NSNotificationCenter.defaultCenter().postNotificationName(kLocationUnknown, object: nil)
            
        } else if error.code == CLError.Denied.rawValue {
            NSNotificationCenter.defaultCenter().postNotificationName(kLocationDenied, object: nil)
            
        } else {
            NSLog("Unknown location error: %@", error)
            
        }

    }
    
    /**
    Tells the app that the authorization status for the application changed.
    
    :param: manager The location manager object reporting the event.
    :param: status  The new authorization status for the application.
    */
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if(status == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
            
            // Might not need this if we just try to update all the time and have the error handler catch the denied option
        } else if(status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted) {
            NSNotificationCenter.defaultCenter().postNotificationName(kLocationDenied, object: nil)
            
        } else if(status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways) {
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
}