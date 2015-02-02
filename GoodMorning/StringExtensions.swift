//
//  StringExtensions.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-27.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

extension String {
    func isEmail() -> Bool {
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
    }
    
    func isName() -> Bool {
        let regex = NSRegularExpression(pattern: "^([a-zA-Z]){3,35}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
    }
    
    func isTaskName() -> Bool {
        if((self as NSString).length > 1 && (self as NSString).length < 255) {
            return true
        }
        
        return false
    }
}