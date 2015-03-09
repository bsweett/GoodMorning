//
//  SoundType.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-08.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

enum SoundType: String {
    case AMBIENT = "ambient", JUNGLE = "jungle", POP = "pop", ALT = "alternative", ELEC = "electronic", ACID = "acid", DEFAULT = "default", NONE = "none"
    
    static let allValues = [AMBIENT, JUNGLE, POP, ALT, ELEC, ACID, DEFAULT, NONE]
    static let displayValues = [AMBIENT.rawValue, JUNGLE.rawValue, POP.rawValue, ELEC.rawValue, ACID.rawValue, DEFAULT.rawValue, NONE.rawValue]
    
    static func typeFromString(string: String) -> SoundType {
        switch(string.lowercaseString) {
        case "ambient":
            return SoundType.AMBIENT
        case "jungle":
            return SoundType.JUNGLE
        case "pop":
            return SoundType.POP
        case "alternative":
            return SoundType.ALT
        case "electronic":
            return SoundType.ELEC
        case "acid":
            return SoundType.ACID
        case "default":
            return SoundType.DEFAULT
        default:
            return SoundType.NONE
        }
    }
}