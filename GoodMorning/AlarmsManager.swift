//
//  AlarmsManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-20.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

class AlarmsManager: NSObject {

    let parser: JSONParser = JSONParser()
    
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
            
            if let reason = json["reason"].stringValue {
                if let message = json["message"].stringValue {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidTaskResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let array = json.arrayValue {
                self.parser.parseAlarmTasks(json)
                return
            }
            
            println("Getting tasks on server failed because response was invalid")
        })
    }
}
