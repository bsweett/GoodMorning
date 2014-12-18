//
//  WeatherManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class WeatherManager : NSObject {
    
    var current = Weather()
    var forcastArray: [Weather] = []
    
    func getWeatherForLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Int {
        
        var code: Int = 0
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        
        let params = ["lat":latitude, "lon":longitude]
        println(params)
        
        Alamofire.request(.GET, url, parameters: params).responseJSON {
            (request, response, JSON, error) in
            if (error != nil) {
                code = error!.code
            } else {
              self.updateWeatherInfo(JSON!)
            }
        }
        
        return code
    }
    
    private func updateWeatherInfo(data: AnyObject) {
        
        var cityname: String
        var country: String
        
        let json = JSON(object: data)
        
        let city: JSON = json["city"]
        cityname = city["name"].stringValue!
        country = city["country"].stringValue!
        
        let list: JSON = json["list"]
        
        // Current Weather
        self.updateCurrentWeather(list, country: country, city: cityname)
        
        // 4 hour forecast
        self.updateForecastWeather(list, country: country, city: cityname)
        
    }
    
    private func updateCurrentWeather(data: JSON, country: String, city: String) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var currenttemperature: Double
        
        let currentItem: JSON = data[0]
        var currentTemp: Double = currentItem["main"]["temp"].doubleValue!
        if(country == "US") {
            currenttemperature = round(((currentTemp - 273.15) * 1.8) + 32)
        } else {
            currenttemperature = round(currentTemp - 273.15)
        }
        var currentIcon: String = currentItem["weather"][0]["icon"].stringValue!
        var currentCond: Int = currentItem["weather"][0]["id"].integerValue!
        
        var currentNight = false
        if currentIcon.rangeOfString("n") != nil{
            currentNight = true
        }
        var now = NSDate()
        
        current.update(currenttemperature, country: country, city: city, time: dateFormatter.stringFromDate(now), condition: currentCond, icon: currentIcon, nighttime: currentNight)
    }
    
    private func updateForecastWeather(data: JSON, country: String, city: String) {
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        for index in 1...4 {
            let item: JSON = data[index]
            
            let main: JSON = item["main"]
            var temp: Double = main["temp"].doubleValue!
            
            var temperature: Double
            
            if(country == "US") {
                temperature = round(((temp - 273.15) * 1.8) + 32)
            } else {
                temperature = round(temp - 273.15)
            }
            
            var date: Double = item["dt"].doubleValue!
            let thisDate = NSDate(timeIntervalSince1970: date)
            let forecastTime = dateFormatter.stringFromDate(thisDate)
            
            let weath: JSON = item["weather"]
            var condition: Int = weath[0]["id"].integerValue!
            var icon: String = weath[0]["icon"].stringValue!
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