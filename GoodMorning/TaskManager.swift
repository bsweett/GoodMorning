//
//  TaskManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-03.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class TaskManager: NSObject {
    
    let parser: JSONParser = JSONParser()
    
    func sendNewTaskRequest(task: Task) {
        let url = SERVER_ADDRESS + "/newtask"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token":token, "time":task.alertTime, "days":task.daysOfTheWeekToString(), "notes":task.notes, "type":task.type.rawValue, "name":task.title]
        
        //GET OR POST?
        Networking.sharedInstance.openNewJSONRequest(.POST, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, AnyObject>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidTaskResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                let bool = result.boolValue()
                dictionary["success"] = bool
                NSNotificationCenter.defaultCenter().postNotificationName("TaskAdded", object: self, userInfo: dictionary)
                
                if bool {
                    NotificationManager.sharedInstance.scheduleNotificationForTask(task)
                }
            }
        })
    }
    
    func getAllTasksRequest() {
        let url = SERVER_ADDRESS + "/tasklist"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        println(token)
        let params = ["token": token, "type": ""]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidTaskResponse", object: self, userInfo: dictionary)
                }
            }
           
            if let array = json.array {
                self.parser.parseAllTasks(json)
                return
            }
        })
    }
    
    func deleteTaskRequest(task: Task) {
        let url = SERVER_ADDRESS + "/deletetask"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        println(token)
        let params = ["token": token, "id": task.id]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidTaskResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                if !result.boolValue() {
                    NSLog("Failed to delete task from server")
                } else {
                    NSLog("Task was deleted from server")
                    
                    NotificationManager.sharedInstance.cancelNotificationsForTask(task)
                }
            }
        })
        
    }
    
    func updateTaskRequest(task: Task) {
        let url = SERVER_ADDRESS + "/updatetask"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token":token, "id": task.id, "time":task.alertTime, "days":task.daysOfTheWeekToString(), "notes":task.notes, "type":task.type.rawValue, "name":task.title]
        
        //GET OR POST?
        Networking.sharedInstance.openNewJSONRequest(.POST, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, AnyObject>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidTaskResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                dictionary["success"] = result.boolValue()
                NSNotificationCenter.defaultCenter().postNotificationName("TaskUpdated", object: self, userInfo: dictionary)
                
            }
        })
    }
    
    // TODO: Test Alarm request. It should only be called if the app is launching not if the application is coming from the installation screen
    func getAllAlarmsRequest() {
        let url = SERVER_ADDRESS + "/tasklist"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        println(token)
        let params = ["token": token, "type": TaskType.ALARM.rawValue]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidTaskResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let array = json.array {
                self.parser.parseAlarmTasks(json)
                return
            }
            
            println("Getting tasks on server failed because response was invalid")
        })
    }
}
