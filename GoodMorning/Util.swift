//
//  Util.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-08.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

// Functions
func ios8() -> Bool {
    if ( NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 ) {
        return false
    } else {
        return true
    }
}

func getUserInfoValueForKey(userinfo: [NSObject : AnyObject]?, key: String) -> String {
    if let info = userinfo as? Dictionary<String,String> {
        if let s = info[key] {
            return s
        }
    }
    
    return internalErrTitle
}

func getImageForCondition(condition: Int, night: Bool) -> UIImage {
    
    var imageName = ""
    
    if(condition < 300) {
        imageName = "thunder"
    } else if (condition < 500) {
        imageName = "drizzle"
    } else if (condition < 600) {
        imageName = "rain"
    } else if (condition < 602) {
        imageName = "snow"
    } else if (condition < 612) {
        imageName = "heavysnow"
    } else if (condition < 700) {
        imageName = "snowandrain"
    } else if (condition < 771) {
        imageName = "fog"
    } else if (condition < 800) {
        imageName = "tornado"
    } else if (condition == 800) {
        imageName = "clear"
    } else if (condition < 804) {
        imageName = "scattered"
    } else if (condition == 804) {
        imageName = "overcast"
    } else if (condition >= 900 && condition <= 902 || condition == 905) {
        imageName = "extreme"
    } else if (condition == 903) {
        imageName = "cold"
    } else if (condition == 904) {
        imageName = "heat"
    } else if (condition > 950 && condition <= 955) {
        imageName = "calm"
    } else if (condition > 955 && condition <= 958) {
        imageName = "windy"
    } else if (condition > 958 && condition < 1000) {
        imageName = "storm"
    } else {
        imageName = "unknown"
    }
    
    if(imageName != "unknown") {
        if(night == true) {
            imageName = "n_" + imageName
        } else {
            imageName = "d_" + imageName
        }
    }
    
    return UIImage(named:(imageName + ".png"))!
}


