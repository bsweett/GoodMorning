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
    
    // TODO: better as a POST with a JSON body?
    func sendNewTaskRequest(task: Task) {
        let url = SERVER_ADDRESS + "/newtask"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token":token, "time":task.alertTime, "days":task.daysOfTheWeekToString(), "notes":task.notes, "type":task.type.rawValue, "name":task.title]
        
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
                self.parser.parseBoolResult(json)
                return
            }
            
            println("Adding new task on server failed because response was invalid")
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
            
            println("Getting tasks on server failed because response was invalid")
        })
    }
    
    func deleteTaskRequest() {
        
    }
    
    func updateTaskRequest() {
        
    }
}