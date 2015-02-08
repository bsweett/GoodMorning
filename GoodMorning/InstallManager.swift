//
//  InstallManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-08.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit
import Alamofire

class InstallManager: NSObject {
   
    let deviceId: String = UIDevice.currentDevice().identifierForVendor.UUIDString
    let parser: JSONParser = JSONParser()
    
    func sendInstallRequestForUser(name: NSString, email: NSString) {
        let url = SERVER_ADDRESS + "/install"
        
        let params = ["device":deviceId, "nickname":name, "email": email]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].stringValue {
                if let message = json["message"].stringValue {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidInstallResponse", object: nil, userInfo: dictionary)
                }
            }
            
            // Checks to make sure token exists and that deviceId returned is the same as the one given on the device
            if let token = json["userToken"].stringValue {
                if(json["deviceId"].stringValue == self.deviceId) {
                    self.parser.parseInstallUserData(json)
                    return
                }
            }

            println("Installation on server failed because user token response was invalid")
        })
    }
}
