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
    
    var mon: Bool!
    var tue: Bool!
    var wed: Bool!
    var thu: Bool!
    var fri: Bool!
    var sat: Bool!
    var sun: Bool!

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

    
    
}