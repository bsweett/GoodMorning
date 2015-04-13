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
    
    /**
    Sends a get request to try and pair a device as a new user account. If an existing user is returned
    then the user if given the option to keep the account or create a new one
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidInstallResponse, object: nil, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                if !result.boolValue() {
                    NSLog("Boolean should not be null for /connectuser request")
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kSafeToInstall, object: nil)
                }
            } else if let token = json["userToken"].string {
                if(json["deviceId"].stringValue == self.deviceId) {
                    self.parser.parseExistingUserData(json)
                    return
                }
            }
        })
        
    }
    
    /**
    Sends a GET request to uninstall an existing user account if an existing one if found
    
    :param: user The user whose account to delete
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidInstallResponse, object: nil, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                if !result.boolValue() {
                    NSLog("Server Error Deleting User Account")
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(kSafeToInstall, object: nil)
                }
            }
        })
    }
    
    /**
    Sends a GET request to install a new user account and device
    
    :param: name  The name of new user
    :param: email The email of the new user
    */
    
    //TODO: Send user interset data
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidInstallResponse, object: nil, userInfo: dictionary)
                }
            }
            
            // Checks to make sure token exists and that deviceId returned is the same as the one given on the device
            if let token = json["userToken"].string {
                if(json["deviceId"].stringValue == self.deviceId) {
                    self.parser.parseInstallUserData(json)
                    return
                }
            }

            NSLog("Installation on server failed because user token response was invalid")
        })
    }

}
