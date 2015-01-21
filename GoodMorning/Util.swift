//
//  Util.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-08.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

let ipHome1 = "http://192.168.1.104:8080"
let ipHome2 = "http://192.168.1.105:8080"

// TODO: Setup router to forward traffic through TCP port 8080 to use static IP
let SERVER_ADDRESS = ipHome2 + "/GoodMorning-Server"

let udEmailID: String = "EMAILUD"
let udToken: String = "TOKENUD"
let udUserID: String = "USERIDUD"
let udUserName: String = "USERNAMEUD"
let udLastActive: String = "LASTACTIVEUD"
let udCreated: String = "CREATEDUD"

let gmOrangeColor: UIColor = UIColor(red: 194, green: 118, blue: 9, alpha: 1)
let gmYellowColor: UIColor = UIColor(red: 255, green: 222, blue: 0, alpha: 1)

let radius: CGFloat = 8

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

extension String {
    func isEmail() -> Bool {
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
    }
    
    func isName() -> Bool {
        let regex = NSRegularExpression(pattern: "^([a-zA-Z]){3,35}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
    }
}
