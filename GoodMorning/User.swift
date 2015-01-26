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
    var email: String
    var userToken: String
    var nickname: String
    var creationDate: NSDate
    var lastActive: NSDate
    
    var tasks: Dictionary<String, Task>
    //var rssFeeds: Dictionary<String, RSSFeed>
    
    // From Existing JSON
    init(id: String, token: String, email: String, name: String, creation: NSDate, lastActive: NSDate) {

        self.userId = id
        self.userToken = token
        self.email = email
        self.nickname = name
        self.creationDate = creation
        self.lastActive = lastActive
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
    
    /**
        Returns an array of tasks that match a given type
    
        :param: type The type of tasks required
    
        :return: [Task] an array of tasks
    */
    func getTasksWithType(type: TaskType) -> Dictionary<String, Task> {
        var results: Dictionary<String, Task> = [:]
        
        for item in self.tasks {
            if(item.1.type == type) {
                results[item.1.id] = item.1
            }
        }
        
        return results
    }
}