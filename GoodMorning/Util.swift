//
//  Util.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-08.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

// TODO: Setup router to forward traffic through TCP port 8080 to use static IP
let SERVER_ADDRESS = "http://192.168.1.106:8080/GoodMorning-Server"

func ios8() -> Bool {
    if ( NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 ) {
        return false
    } else {
        return true
    }
}

func getUserInfoMessage(userinfo: [NSObject : AnyObject]?) -> String {
    if let info = userinfo as? Dictionary<String,String> {
        if let s = info["message"] {
            return s
        }
    }
    
    println("Internal notification has an invalid userinfo dictionary message")
    return ""
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
