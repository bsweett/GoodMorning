//
//  AlertType.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

enum AlertType: String {
    case NOTIFICATION = "Notification", SOUND = "Sound", VIBERATE = "Viberate", ALL = "All", NONE = "None"
    
    static let allValues = [NOTIFICATION, SOUND, VIBERATE, ALL, NONE]
    
    static func valueFromString(string: String) -> AlertType {
        switch(string) {
        case "Notification":
            return AlertType.NOTIFICATION
        case "Sound":
            return AlertType.SOUND
        case "Viberate":
            return AlertType.VIBERATE
        case "All":
            return AlertType.ALL
        default:
            return AlertType.NONE
        }
    }
}
