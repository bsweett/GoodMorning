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
    var soundFileName: String
    
    var mon: Bool = false
    var tue: Bool = false
    var wed: Bool = false
    var thu: Bool = false
    var fri: Bool = false
    var sat: Bool = false
    var sun: Bool = false

    var notes: String
    var deepLink: DeepLinkType
    
    // From existing JSON
    init(id: String, title: String, creation: NSDate, nextAlert: NSDate, type: TaskType, link: DeepLinkType, alertTime: String, soundFileName: String, notes: String) {
        
        self.id = id
        self.title = title
        self.creationDate = creation
        self.nextAlertDate = nextAlert
        self.type = type
        self.alertTime = alertTime
        self.soundFileName = soundFileName
        self.notes = notes
        self.deepLink = link
        
    }
    
    // New task from UI
    init(title: String, type: TaskType, alertTime: String, soundFileName: String, notes: String) {
        
        let today = NSDate()
        let newId = NSUUID().UUIDString
        
        self.id = newId
        self.title = title
        self.type = type
        self.creationDate = today
        self.alertTime = alertTime
        self.soundFileName = soundFileName
        self.notes = notes
        
        self.deepLink = DeepLinkType.NONE
        self.nextAlertDate = today
        
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
    
    func daysOfTheWeekToString() -> String {
        var output = ""
        
        mon ? (output = output + "1") : (output = output + "0")
        tue ? (output = output + "1") : (output = output + "0")
        wed ? (output = output + "1") : (output = output + "0")
        thu ? (output = output + "1") : (output = output + "0")
        fri ? (output = output + "1") : (output = output + "0")
        sat ? (output = output + "1") : (output = output + "0")
        sun ? (output = output + "1") : (output = output + "0")
        
        return output
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
        
        if isEveryDayRepeated() {
            output = "Every Day"
        }
        
        if isNeverRepeated() {
            output = "Never"
        }
        
        return output
    }
    
    func isEveryDayRepeated() -> Bool {
        if mon && tue && wed && thu && fri && sat && sun {
            return true
        }
        
        return false
    }
    
    func isNeverRepeated() -> Bool {
        if !mon && !tue && !wed && !thu && !fri && !sat && !sun {
            return true
        }
        
        return false
    }
    
    func getSoundFileNameForPlayback() -> String? {
        if soundFileName == "" {
            return nil
        } else if soundFileName == SoundType.DEFAULT.rawValue {
            return UILocalNotificationDefaultSoundName
        } else {
            return soundFileName.lowercaseString + ".wav"
        }
    }

    /**
        Returns the display preview for the notes field. Caps it at 100 characters.
    */
    func notesDisplayPreview() -> String {
        var preview = ""
        
        if((notes as NSString).length > 100) {
            let rangeOfPreview = Range(start: notes.startIndex, end: advance(notes.startIndex, 100))
            preview = notes.substringWithRange(rangeOfPreview)
        } else {
            preview = notes
        }
        
        return preview
    }
    
    func displayAlertTime() -> String {
        var result = ""
        
        //"07:00:00 AM"
        if alertTime != "" {
            var time = alertTime
            result = (alertTime[0...4]) + " " + (time[9...10])
        }
        //"07:00 AM"
        
        return result
    }
    
    func displaySoundEnabledFlag() -> String {
        if (soundFileName == "" || soundFileName == SoundType.NONE.rawValue) {
            return "Notification"
        } else {
            return "Sound & Notification"
        }
    }
    
    func getNotifBody() -> String {
        return self.title + " (" + self.type.rawValue + ")" + " at " + self.alertTime + " " + self.notes
    }
}