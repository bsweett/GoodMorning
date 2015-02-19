//
//  Networking.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-08.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation
import Alamofire

class Networking: NSObject {
    
    var manager: Alamofire.Manager
    var networkOperationCount: Int
    
    class var sharedInstance : Networking {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : Networking? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = Networking()
        }
        return Static.instance!
    }
    
    override init() {
        let configuration  = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = 7200
        configuration.timeoutIntervalForRequest = 20
        manager = Alamofire.Manager(configuration: configuration)
        networkOperationCount = 0
    }
    
    private func didStartNetworkOperation() {
        assert(NSThread.isMainThread())
        self.networkOperationCount += 1
    }
    
    private func didStopNetworkOperation() {
        assert(NSThread.isMainThread());
        assert(self.networkOperationCount > 0);
        self.networkOperationCount -= 1;
    }
    
    // NOTE: Not using Alamofire method
    func openNewJSONRequest(method: Alamofire.Method, url: String, parameters: [String: AnyObject], completion: ((data: JSON) -> Void)!) {
        
        self.didStartNetworkOperation()
        
        Alamofire.request(.GET, url, parameters: parameters).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON {
            (request, response, json, error) in
            
            self.didStopNetworkOperation()
            
            if (error != nil) {
                println( error?.localizedDescription)
                NSNotificationCenter.defaultCenter().postNotificationName("NetworkError", object: nil)
                
            } else {
                let json = JSON(json!)
                var dictionary = Dictionary<String, String>()
                let message = json["message"].string
                let reason = json["reason"].string
                
                if(reason == "Exception" && message != "") {
                    dictionary["message"] = message
                    NSNotificationCenter.defaultCenter().postNotificationName("InternalServerError", object: nil, userInfo: dictionary)
                    
                } else if(reason == "" && message != "") {
                    // Generic message from server
                    println("Server said: " , message)
                    
                } else {
                    completion(data: json)
                    
                }
                
            }
            
        }
    }
    
    // NOTE: Not using Alamofire method
    func openNewXMLRequest(method: Alamofire.Method, url: String, completion: ((data: AEXMLDocument) -> Void)!) {
        
        self.didStartNetworkOperation()
        
        Alamofire.request(.GET, url).validate(statusCode: 200..<300).validate(contentType: ["text/xml"]).responseString {
            (request, response, string, error) in
            
            self.didStopNetworkOperation()
            
            if (error != nil) {
                println( error?.localizedDescription)
                NSNotificationCenter.defaultCenter().postNotificationName("NetworkError", object: nil)
                
            } else {
                let xmlData = string?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                var err: NSError?
                if let xml = AEXMLDocument(xmlData: xmlData!, error: &err) {
                    
                    var dictionary = Dictionary<String, String>()
                    let message = xml.root["message"].value
                    let reason = xml.root["reason"].value
                    
                    if(reason == "Exception" && message != "") {
                        dictionary["message"] = message
                        NSNotificationCenter.defaultCenter().postNotificationName("InternalServerError", object: nil, userInfo: dictionary)
                        
                    } else if(reason == "" && message != "") {
                        // Generic message from server
                        println("Server said: " , message)
                        
                    } else {
                        completion(data: xml)
                        
                    }
                    
                } else {
                    
                    // TODO: RSS XML Parse error
                    println("description: \(error?.localizedDescription)\ninfo: \(err?.userInfo)")
                }
            }
        }
    }
}