//
//  TaskType.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

enum TaskType: String {
    case CHORE = "Chore", TRAVEL = "Travel", ENTERTAINMENT = "Entertainment", ALARM = "Alarm", UNKNOWN = ""
    
    static let allValues = [CHORE, TRAVEL, ENTERTAINMENT, ALARM, UNKNOWN]
    static let displayValues = [CHORE.rawValue, TRAVEL.rawValue, ENTERTAINMENT.rawValue, ALARM.rawValue]
    
    static func typeFromString(string: String) -> TaskType {
        switch(string) {
        case "Chore":
            return TaskType.CHORE
        case "Travel":
            return TaskType.TRAVEL
        case "Entertainment":
            return TaskType.ENTERTAINMENT
        case "Alarm":
            return TaskType.ALARM
        default:
            return TaskType.UNKNOWN
        }
    }
}

