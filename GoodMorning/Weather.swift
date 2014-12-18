//
//  Weather.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation

class Weather: NSObject {
    
    var temperature: Double = 0;
    var country: String = "";
    var city: String = "";
    var time: String = "";
    var condition: Int = 0
    var icon: String = ""
    var nighttime: Bool = false
    
    func update(temp: Double, country: String, city: String, time: String, condition: Int, icon: String, nighttime: Bool) {
        self.temperature = temp
        self.country = country
        self.city = city
        self.time = time
        self.condition = condition
        self.icon = icon
        self.nighttime = nighttime
    }
    
    func getImageName() {
        if nighttime == true {
            
        } else {
            
        }
    }
    
}