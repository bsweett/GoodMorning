//
//  WeatherManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class WeatherManager : NSObject {
    
    var current = Weather()
    var forcastArray: [Weather] = []
    
    /**
    Gets the weather for the weather api using the lat and long provided by the location manager. Sends 
    a notification when the forcast has been parsed
    
    :param: latitude  Represents a latitude value specified in degrees.
    :param: longitude Represents a  longitude value specified in degrees.
    */
    func getWeatherForLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        let url = WEATHER_ADDRESS
        
        let params = ["lat":latitude, "lon":longitude]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            var cityname: String
            var country: String
            
            let json = data
            
            if json != nil {
                let city: JSON = json["city"]
                cityname = city["name"].string!
                country = city["country"].string!
                
                let list: JSON = json["list"]
                
                // Current Weather
                self.updateCurrentWeather(list, country: country, city: cityname)
                
                // 4 hour forecast
                self.updateForecastWeather(list, country: country, city: cityname)
                
                CoreDataManager.sharedInstance.clearAllObjectsInEntity("Weather")
                CoreDataManager.sharedInstance.saveWeather(self.current)
                
                // Send notification
                NSNotificationCenter.defaultCenter().postNotificationName(kWeatherUpdated, object: nil, userInfo:["current": self.current, "forecast1": self.forcastArray[0], "forecast2": self.forcastArray[1], "forecast3": self.forcastArray[2], "forecast4": self.forcastArray[3]])
            
            } else {
                NSLog("ERROR: Open Weather API callback failed")
            }
        })
    }
    
    /**
    Updates the current weather object from JSON data
    
    :param: data    The JSON data to parse
    :param: country The country the weather is from
    :param: city    The city the weather is from
    */
    private func updateCurrentWeather(data: JSON, country: String, city: String) {
        
        var dateFormatter = NSDateFormatter()
        var twelveHourLocale = NSLocale(localeIdentifier:"en_US_POSIX")
        dateFormatter.locale = twelveHourLocale
        dateFormatter.dateFormat = "HH:mm a"
        
        var currenttemperature: Double
        
        let currentItem: JSON = data[0]
        var currentTemp: Double = currentItem["main"]["temp"].double!
        if(country == "US") {
            currenttemperature = round(((currentTemp - 273.15) * 1.8) + 32)
        } else {
            currenttemperature = round(currentTemp - 273.15)
        }
        var currentIcon: String = currentItem["weather"][0]["icon"].string!
        var currentCond: Int = currentItem["weather"][0]["id"].int!
        
        var currentNight = false
        if currentIcon.rangeOfString("n") != nil{
            currentNight = true
        }
        
        cacheNightValue(currentNight)
        
        var now = NSDate()
        
        current.update(currenttemperature, country: country, city: city, time: dateFormatter.stringFromDate(now), condition: currentCond, icon: currentIcon, nighttime: currentNight)
    }
    
    /**
    Caches and checks the cache for the night day boolean. If its changed it sends a notification
    
    :param: newValue The new night day bool to save in the cache
    */
    private func cacheNightValue(newValue: Bool) {
        
        let cachedValue: Bool = UserDefaultsManager.sharedInstance.getNight().boolValue()
        
        if(newValue != cachedValue) {
            UserDefaultsManager.sharedInstance.saveNight(newValue.toString())
            NSNotificationCenter.defaultCenter().postNotificationName(kNightCachedChanged, object: nil)
        }
    }
    
    /**
    Updates the forcast weather objects from JSON data
    
    :param: data    The JSON data to parse
    :param: country The country the weather is from
    :param: city    The city the weather is from
    */
    private func updateForecastWeather(data: JSON, country: String, city: String) {
        
        var dateFormatter = NSDateFormatter()
        var twelveHourLocale = NSLocale(localeIdentifier:"en_US_POSIX")
        dateFormatter.locale = twelveHourLocale
        dateFormatter.dateFormat = "HH:mm a"
        
        for index in 1...4 {
            let item: JSON = data[index]
            
            let main: JSON = item["main"]
            var temp: Double = main["temp"].double!
            
            var temperature: Double
            
            if(country == "US") {
                temperature = round(((temp - 273.15) * 1.8) + 32)
            } else {
                temperature = round(temp - 273.15)
            }
            
            var date: Double = item["dt"].double!
            let thisDate = NSDate(timeIntervalSince1970: date)
            let forecastTime = dateFormatter.stringFromDate(thisDate)
            
            let weath: JSON = item["weather"]
            var condition: Int = weath[0]["id"].int!
            var icon: String = weath[0]["icon"].string!
            var night = false;
            if icon.rangeOfString("n") != nil{
                night = true
            }
            
            var weather: Weather = Weather()
            weather.update(temperature, country: country, city: city, time: forecastTime, condition: condition, icon: icon, nighttime: night)
            self.forcastArray.append(weather)
        }
    }
    
}