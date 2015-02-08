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
    
    func removeCharsFromEnd(count:Int) -> String{
        let stringLength = countElements(self)
        
        let substringIndex = (stringLength < count) ? 0 : stringLength - count
        
        return self.substringToIndex(advance(self.startIndex, substringIndex))
    }
    
    func length() -> Int {
        return countElements(self)
    }
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}