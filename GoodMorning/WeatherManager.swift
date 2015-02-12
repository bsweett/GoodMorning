//
//  WeatherManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherManager : NSObject {
    
    var current = Weather()
    var forcastArray: [Weather] = []
    
    func getWeatherForLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        
        let params = ["lat":latitude, "lon":longitude]
        //println(params)
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            var cityname: String
            var country: String
            
            let json = data
            
            let city: JSON = json["city"]
            cityname = city["name"].string!
            country = city["country"].string!
            
            let list: JSON = json["list"]
            
            // Current Weather
            self.updateCurrentWeather(list, country: country, city: cityname)
            
            // 4 hour forecast
            self.updateForecastWeather(list, country: country, city: cityname)
            
            // Send notification
            NSNotificationCenter.defaultCenter().postNotificationName("WeatherUpdated", object: nil, userInfo:["current": self.current, "forecast1": self.forcastArray[0], "forecast2": self.forcastArray[1], "forecast3": self.forcastArray[2], "forecast4": self.forcastArray[3]])
        })
    }
    
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
    
    private func cacheNightValue(newValue: Bool) {
        
        let cachedValue: Bool = UserDefaultsManager.sharedInstance.getNight().boolValue()
        
        if(newValue != cachedValue) {
            println("Changed")
            
            UserDefaultsManager.sharedInstance.saveNight(newValue.toString())
            NSNotificationCenter.defaultCenter().postNotificationName("NightCachedChanged", object: nil)
        }
    }
    
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