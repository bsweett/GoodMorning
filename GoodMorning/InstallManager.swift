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
    
    
    func sendNewAppConnectionRequest() {
        let url = SERVER_ADDRESS + "/connectuser"
        
        let params = ["device" : deviceId]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidInstallResponse", object: nil, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                if !result.boolValue() {
                    NSLog("Boolean should not be null for /connectuser request")
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName("SafeToInstall", object: nil)
                }
            } else if let token = json["userToken"].string {
                if(json["deviceId"].stringValue == self.deviceId) {
                    self.parser.parseExistingUserData(json)
                    return
                }
            }
        })
        
    }
    
    func sendUninstallRequestForUser(user: User) {
        let url = SERVER_ADDRESS + "/uninstall"
        
        let params = ["token": user.userToken, "device":deviceId]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidInstallResponse", object: nil, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                if !result.boolValue() {
                    NSLog("Server Error Deleting User Account")
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName("SafeToInstall", object: nil)
                }
            }
        })
    }
    
    func sendInstallRequestForUser(name: NSString, email: NSString) {
        let url = SERVER_ADDRESS + "/install"
        
        let params = ["device":deviceId, "nickname":name, "email": email]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidInstallResponse", object: nil, userInfo: dictionary)
                }
            }
            
            // Checks to make sure token exists and that deviceId returned is the same as the one given on the device
            if let token = json["userToken"].string {
                if(json["deviceId"].stringValue == self.deviceId) {
                    self.parser.parseInstallUserData(json)
                    return
                }
            }

            println("Installation on server failed because user token response was invalid")
        })
    }

}
