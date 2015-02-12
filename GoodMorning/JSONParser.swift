//
//  JSONParser.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-07.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class JSONParser: NSObject {
   
    var dateFormatter: NSDateFormatter!
    
    override init() {
        super.init()
        dateFormatter = NSDateFormatter()
        
        //Jan 9, 2015 6:52:14 PM
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
    }
    
    func parseInstallUserData(userData: JSON) {

        let tempDate: NSDate = NSDate()
        
        let userId: String = userData["userId"].string!
        let deviceId: String = userData["deviceId"].string!
        let token: String = userData["userToken"].string!
        let nickname: String = userData["nickname"].string!
        let email: String = userData["email"].string!
        let creationString: String = userData["creationDate"].string!
        let lastActiveString: String = userData["lastActive"].string!
        
        let creationDate: NSDate = dateFormatter.dateFromString(creationString)!
        let lastActiveDate: NSDate = dateFormatter.dateFromString(lastActiveString)!
        
        var user: User = User(id: userId, token: token, email: email, name: nickname, creation: creationDate, lastActive: lastActiveDate)
        
        // TODO: Pass feeds to user object constructor
        if let list: Array<JSON> = userData["rssFeeds"].array {
            
            
        }
        
        //If not a Array or nil, return []
        if let list: Array<JSON> = userData["taskSet"].array {
            
            for task in list {
                let taskId = task["taskId"].string!
                let taskName = task["name"].string!
                let taskTypeString = task["taskType"].string!
                let taskCreateString = task["creationTimestamp"].string!
                let taskNextAlertString = task["nextAlertTimestamp"].string!
                let taskAlertTimeString = task["alertTime"].string!
                let soundEnabled = task["soundFileName"].string!
                let notes = task["Notes"].string!
                
                let monday = task["monday"].boolValue
                let tuesday = task["tuesday"].boolValue
                let wednesday = task["wednesday"].boolValue
                let thursday = task["thursday"].boolValue
                let friday = task["friday"].boolValue
                let saturday = task["saturday"].boolValue
                let sunday = task["sunday"].boolValue
                
                let tType = TaskType.typeFromString(taskTypeString)
                
                let taskCreateDate: NSDate = dateFormatter.dateFromString(taskCreateString)!
                let taskNexAlertDate: NSDate = dateFormatter.dateFromString(taskNextAlertString)!
                
                var task: Task = Task(id: taskId, title: taskName, creation: taskCreateDate, nextAlert: taskNexAlertDate, type: tType, alertTime: taskAlertTimeString, soundFileName: soundEnabled, notes: notes)
                task.setDaysOfTheWeek(monday, tue: tuesday, wed: wednesday, thu: thursday, fri: friday, sat: saturday, sun: sunday)
                user.addTask(task)
            }
            
        }
        
        UserDefaultsManager.sharedInstance.saveUserData(user)
        NSNotificationCenter.defaultCenter().postNotificationName("InstallComplete", object: self, userInfo: user.getTasksWithType(TaskType.ALARM))
    }
    
    func parseBoolResult(result: JSON) {
        
    }
    
    func parseAllTasks(taskData: JSON) {
        let taskList: Dictionary<String, Task>! = parseTaskList(taskData)
        NSNotificationCenter.defaultCenter().postNotificationName("TaskListUpdated", object: self, userInfo: taskList)
    }
    
    func parseAlarmTasks(taskData: JSON) {
        let taskList: Dictionary<String, Task>! = parseTaskList(taskData)
        NSNotificationCenter.defaultCenter().postNotificationName("AlarmListUpdated", object: self, userInfo: taskList)
    }
    
    private func parseTaskList(taskData: JSON) -> Dictionary<String, Task> {
        
        let tempDate: NSDate = NSDate()
        var taskList: Dictionary<String, Task>! = [:]
        
        if let list: Array<JSON> = taskData.array {
            
            for task in list {
                let taskId = task["taskId"].string!
                let taskName = task["name"].string!
                let taskTypeString = task["taskType"].string!
                let taskCreateString = task["creationTimestamp"].string!
                let taskNextAlertString = task["nextAlertTimestamp"].string!
                let taskAlertTimeString = task["alertTime"].string!
                let soundEnabled = task["soundFileName"].string!
                let notes = task["Notes"].string!
                
                let monday = task["monday"].boolValue
                let tuesday = task["tuesday"].boolValue
                let wednesday = task["wednesday"].boolValue
                let thursday = task["thursday"].boolValue
                let friday = task["friday"].boolValue
                let saturday = task["saturday"].boolValue
                let sunday = task["sunday"].boolValue
                
                let tType = TaskType.typeFromString(taskTypeString)
                
                let taskCreateDate: NSDate = dateFormatter.dateFromString(taskCreateString)!
                let taskNexAlertDate: NSDate = dateFormatter.dateFromString(taskNextAlertString)!
                
                var task: Task = Task(id: taskId, title: taskName, creation: taskCreateDate, nextAlert: taskNexAlertDate, type: tType, alertTime: taskAlertTimeString, soundFileName: soundEnabled, notes: notes)
                task.setDaysOfTheWeek(monday, tue: tuesday, wed: wednesday, thu: thursday, fri: friday, sat: saturday, sun: sunday)
                taskList[task.title] = task
            }
        }
        
        return taskList
    }
    
}
