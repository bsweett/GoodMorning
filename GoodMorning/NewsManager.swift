//
//  NewsManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-18.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class NewsManager: NSObject {
   
    let xmlParser = XMLParser()
    
    func testNewRSSUrl(url: String, type: RSSType) {
        
        Networking.sharedInstance.openNewXMLRequest(.GET, url: url, {(data: AEXMLDocument) in
            
            println("XML:", data.xmlString)
            let newRSSFeed: RSSFeed? = self.xmlParser.checkValidRSSChannel(data, type: type, url: url)
            
            if newRSSFeed == nil {
                NSNotificationCenter.defaultCenter().postNotificationName("InvalidRSSURL", object: self)
            } else {
                var dictionary = Dictionary<String, AnyObject>()
                dictionary["feed"] = newRSSFeed
                
                println(newRSSFeed?.toString())
            
                NSNotificationCenter.defaultCenter().postNotificationName("ShowRSSPreview", object: self, userInfo: dictionary)
            }
            
        })
        
    }
    
}
