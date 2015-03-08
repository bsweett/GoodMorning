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
            
            if let result = json["success"].bool {
                dictionary["success"] = result
                NSNotificationCenter.defaultCenter().postNotificationName("TaskAdded", object: self, userInfo: dictionary)
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
            
            if let result = json["success"].bool {
                if !result {
                    NSLog("Failed to delete task from server")
                } else {
                    NSLog("Task was deleted from server")
                }
            }
        })
        
    }
    
    func updateTaskRequest(task: Task) {
        let url = SERVER_ADDRESS + "/updatetask"
        
        NSLog("TODO")
    }
}
