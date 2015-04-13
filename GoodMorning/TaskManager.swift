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
    
    /**
    Sends a post request for a new task to the server for a given task object
    
    :param: task The task object with all of its content to add
    */
    func sendNewTaskRequest(task: Task) {
        let url = SERVER_ADDRESS + "/newtask"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token":token, "time":task.alertTime, "days":task.daysOfTheWeekToString(), "notes":task.notes, "type":task.type.rawValue, "name":task.title]
        
        Networking.sharedInstance.openNewJSONRequest(.POST, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, AnyObject>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidTaskRespone, object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                let bool = result.boolValue()
                dictionary["success"] = bool
                NSNotificationCenter.defaultCenter().postNotificationName(kTaskAdded, object: self, userInfo: dictionary)
                
                if bool {
                    NotificationManager.sharedInstance.scheduleNotificationForTask(task)
                }
            }
        })
    }
    
    /**
    Makes a get request to the server for all list of all the tasks
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidTaskRespone, object: self, userInfo: dictionary)
                }
            }
           
            if let array = json.array {
                self.parser.parseAllTasks(json)
                return
            }
        })
    }
    
    /**
    Sends a get request to delete a given task
    
    :param: task The task to delete from the server
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidTaskRespone, object: self, userInfo: dictionary)
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
    
    /**
    Sends a task to update on the server
    
    :param: task the task object to update. It should have the same id of an existing task
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidTaskRespone, object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                dictionary["success"] = result.boolValue()
                NSNotificationCenter.defaultCenter().postNotificationName(kTaskUpdated, object: self, userInfo: dictionary)
                
            }
        })
    }
    
    /**
    Gets a list of tasks that are of type alarm from the server
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidTaskRespone, object: self, userInfo: dictionary)
                }
            }
            
            if let array = json.array {
                self.parser.parseAlarmTasks(json)
                return
            }
            
            NSLog("Getting tasks on server failed because response was invalid")
        })
    }
}
