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
    var alertTime: NSDate
    var alertType: AlertType
    var media: MPMediaItem
    var repeat: RepeatType
    var notes: String
    
    // From existing JSON
    init(id: String, title: String, creation: NSDate, nextAlert: NSDate, type: TaskType, alertTime: NSDate, alert: AlertType, media: MPMediaItem, repeat: RepeatType, notes: String) {
        
        self.id = id
        self.title = title
        self.creationDate = creation
        self.nextAlertDate = nextAlert
        self.type = type
        self.alertTime = alertTime
        self.alertType = alert
        self.media = media
        self.repeat = repeat
        self.notes = notes
        
    }
    
    // New task from UI
    init(title: String, type: TaskType, alertTime: NSDate, alertType: AlertType, repeat: RepeatType, notes: String) {
        
        let today = NSDate()
        let newId = NSUUID().UUIDString
        
        self.id = newId
        self.title = title
        self.type = type
        self.creationDate = today
        self.alertTime = alertTime
        self.alertType = alertType
        self.repeat = repeat
        self.notes = notes
        
        // TODO: Set next alert based on alerttime and creatition date
        // TODO: Fill in missing items
        self.nextAlertDate = today
        self.media = MPMediaItem()
        
    }

    
    
}