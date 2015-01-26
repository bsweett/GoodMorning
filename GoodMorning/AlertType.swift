//
//  AlertType.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

enum AlertType: String {
    case NOTIFICATION = "notification", SOUND = "sound", VIBERATE = "viberate", ALL = "all", NONE = ""
    
    static let allValues = [NOTIFICATION, SOUND, VIBERATE, ALL, NONE]
    
    static func valueFromString(string: String) -> AlertType {
        switch(string) {
        case "notification":
            return AlertType.NOTIFICATION
        case "sound":
            return AlertType.SOUND
        case "viberate":
            return AlertType.VIBERATE
        case "all":
            return AlertType.ALL
        default:
            return AlertType.NONE
        }
    }
}
