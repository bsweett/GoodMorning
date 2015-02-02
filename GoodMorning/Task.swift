//
//  Task.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import MediaPlayer

class Task: NSObject {
    
    var id: String
    var title: String
    var creationDate: NSDate
    var nextAlertDate: NSDate
    var type: TaskType
    var alertTime: String
    var alertType: AlertType
    //var media: MPMediaItem
    
    var mon: Bool = false
    var tue: Bool = false
    var wed: Bool = false
    var thu: Bool = false
    var fri: Bool = false
    var sat: Bool = false
    var sun: Bool = false

    var notes: String
    
    // From existing JSON
    init(id: String, title: String, creation: NSDate, nextAlert: NSDate, type: TaskType, alertTime: String, alert: AlertType, notes: String) {
        
        self.id = id
        self.title = title
        self.creationDate = creation
        self.nextAlertDate = nextAlert
        self.type = type
        self.alertTime = alertTime
        self.alertType = alert
        self.notes = notes
        
    }
    
    // New task from UI
    init(title: String, type: TaskType, alertTime: String, alertType: AlertType, notes: String) {
        
        let today = NSDate()
        let newId = NSUUID().UUIDString
        
        self.id = newId
        self.title = title
        self.type = type
        self.creationDate = today
        self.alertTime = alertTime
        self.alertType = alertType
        self.notes = notes
        
        // TODO: Set next alert based on alerttime and creatition date
        // TODO: Fill in missing items
        self.nextAlertDate = today
        //self.media = MPMediaItem()
        
    }
    
    func setDaysOfTheWeek(mon: Bool, tue: Bool, wed: Bool, thu: Bool, fri: Bool, sat: Bool, sun: Bool) {
        
        self.mon = mon
        self.tue = tue
        self.wed = wed
        self.thu = thu
        self.fri = fri
        self.sat = sat
        self.sun = sun
        
    }
    
    func setDaysOfTheWeekFromString(values: String) {
        let characters = Array(values)
        if(characters.count == 7) {
            characters[0] == "1" ? ( mon = true ) : ( mon = false )
            characters[1] == "1" ? ( tue = true ) : ( tue = false )
            characters[2] == "1" ? ( wed = true ) : ( wed = false )
            characters[3] == "1" ? ( thu = true ) : ( thu = false )
            characters[4] == "1" ? ( fri = true ) : ( fri = false )
            characters[5] == "1" ? ( sat = true ) : ( sat = false )
            characters[6] == "1" ? ( sun = true ) : ( sun = false )
        }
    }
    
    func daysOfWeekFromDictionary(dictionary: Dictionary<Int, Bool> ) {
        if(dictionary.count == 7) {
            mon = dictionary[0]!
            tue = dictionary[1]!
            wed = dictionary[2]!
            thu = dictionary[3]!
            fri = dictionary[4]!
            sat = dictionary[5]!
            sun = dictionary[6]!
        }
    }
    
    func daysOfWeekToDictionary() -> Dictionary<Int, Bool> {
        var dictionary = Dictionary<Int, Bool>()
        dictionary[0] = mon
        dictionary[1] = tue
        dictionary[2] = wed
        dictionary[3] = thu
        dictionary[4] = fri
        dictionary[5] = sat
        dictionary[6] = sun
        
        return dictionary
    }
    
    func daysOfWeekToDisplayString() -> String {
        var output: String = ""
        
        mon ? (output = output + "Mon ") : (output = output + "")
        tue ? (output = output + "Tue ") : (output = output + "")
        wed ? (output = output + "Wed ") : (output = output + "")
        thu ? (output = output + "Thu ") : (output = output + "")
        fri ? (output = output + "Fri ") : (output = output + "")
        sat ? (output = output + "Sat ") : (output = output + "")
        sun ? (output = output + "Sun ") : (output = output + "")
        
        if mon && tue && wed && thu && fri && sat && sun {
            output = "Every Day"
        }
        
        if !mon && !tue && !wed && !thu && !fri && !sat && !sun {
            output = "Never"
        }
        
        return output
    }

    
    
}