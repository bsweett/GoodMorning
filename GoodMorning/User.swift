//
//  User.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-18.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class User : NSObject {
    
    var userId: String
    var deviceId: String
    var userToken: String
    var nickname: String
    var creationDate: NSDate
    var lastActive: NSDate
    
    var tasks: Dictionary<String, Task>
    //var rssFeeds: Dictionary<String, RSSFeed>
    
    // From Existing JSON
    init(id: String, device: String, token: String, name: String, creation: NSDate, lastActive: NSDate) {
        self.userId = id
        self.deviceId = device
        self.userToken = token
        self.nickname = name
        self.creationDate = creation
        self.lastActive = lastActive
        
        // TODO Tasks?
        self.tasks = [:]
    }
    
    // New from first launch (after everything is confirmed with server)
    init(id: String, name: String, token: String) {
        
        // This is done again here to make sure nothing changed from the time the server built the
        // token till the user object is created on the client
        let deviceId = UIDevice.currentDevice().identifierForVendor.UUIDString
        
        self.userId = id
        self.deviceId = deviceId
        self.userToken = token
        self.nickname = name
        self.creationDate = NSDate()
        self.lastActive = NSDate()
        
        self.tasks = [:]
    }
    
    func addTask(task: Task) {
        self.tasks[task.id] = task
    }
    
    func removeTask(task: Task) {
        if(self.tasks.count > 0) {
            self.tasks.removeValueForKey(task.id)
        }
    }
}