//
//  Util.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-08.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

let ipHome1 = "http://192.168.1.101:8080"
let ipHome4 = "http://192.168.1.104:8080"
let ipHome5 = "http://192.168.1.105:8080"
let ipHome7 = "http://192.168.1.107:8080"

// TODO: Setup router to forward traffic through TCP port 8080 to use static IP
let SERVER_ADDRESS = ipHome7 + "/GoodMorning-Server"

// UserDefault Keys
let udEmailID: String = "EMAILUD"
let udToken: String = "TOKENUD"
let udUserID: String = "USERIDUD"
let udUserName: String = "USERNAMEUD"
let udLastActive: String = "LASTACTIVEUD"
let udCreated: String = "CREATEDUD"

let udNight: String = "NIGHTUD"

// Colors
let gmOrangeColor: UIColor = UIColor(red: (194/255.0), green: (118/255.0), blue: (9/255.0), alpha: 1.0)
let gmYellowColor: UIColor = UIColor(red: (225/255.0), green: (222/255.0), blue: (0/255.0), alpha: 1.0)

// Numbers
let radius: CGFloat = 8

// Font
let gmFontQuote: UIFont = UIFont(name: "Avenir-MediumOblique", size: 15)!
let gmFontNormal: UIFont = UIFont(name: "Avenir-Medium", size: 17)!
let gmFontBold: UIFont = UIFont(name: "Avenir-Heavy", size: 18)!

// Strings
let UNKNOWN: String = "UNKNOWN"

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
    
    return "Internal Server Error"
}


