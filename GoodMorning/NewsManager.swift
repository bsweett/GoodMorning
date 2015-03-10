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
    let jsonParser = JSONParser()
    
    func testNewRSSUrl(url: String, type: RSSType) {
        
        Networking.sharedInstance.openNewXMLRequest(.GET, url: url, {(data: AEXMLDocument) in
            
            println("XML:", data.xmlString)
            let newRSSFeed: RSSFeed? = self.xmlParser.checkValidRSSChannel(data, type: type, url: url)
            
            if newRSSFeed == nil {
                NSNotificationCenter.defaultCenter().postNotificationName("InvalidRSSURL", object: self)
            } else {
                var dictionary = Dictionary<String, RSSFeed>()
                dictionary["feed"] = newRSSFeed
                
                println(newRSSFeed?.toString())
            
                NSNotificationCenter.defaultCenter().postNotificationName("ShowRSSPreview", object: self, userInfo: dictionary)
            }
            
        })
        
    }
    
    func getFeedsForQuery(query: String) {
        
        let url = FEEDLY_ADDRESS + "search/feeds"
        let params = ["query": query]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, completion: {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, AnyObject>()
            
            println(json)
            
            if let array = json["results"].array {
                self.jsonParser.parseFeedlyFeeds(array, query: query)
            }
        })
        
    }
    
    func saveValidFeedToServer(feed: RSSFeed) {
        let url = SERVER_ADDRESS + "/newfeed"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token":token, "title":feed.title, "type":feed.type.rawValue, "updated":feed.lastActiveDate.toRFC822String(), "link":feed.link, "description":feed.contentDescription, "source":feed.rssLink, "lang": feed.language]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, completion: {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, AnyObject>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidFeedResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                dictionary["success"] = result.boolValue()
                NSNotificationCenter.defaultCenter().postNotificationName("NewsAdded", object: self, userInfo: dictionary)
            }
        })

    }
    
    func getAllFeedsRequest() {
        let url = SERVER_ADDRESS + "/feedlist"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token": token, "type": ""]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, completion: {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidFeedResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let array = json.array {
                self.jsonParser.parseAllFeeds(json)
                return
            }
            
            println("Getting feeds on server failed because response was invalid")
        })
    }
    
    func deleteFeedRequest(rssfeed: RSSFeed) {
        let url = SERVER_ADDRESS + "/deletefeed"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token": token, "id": rssfeed.id]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, String>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName("InvalidFeedResponse", object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                if !result.boolValue() {
                    NSLog("Failed to delete feed from server")
                } else {
                    NSLog("Feed was deleted from server")
                }
            }
        })
    }
    
    func getArticlesForFeed(rssfeed: RSSFeed) {
        let url = rssfeed.rssLink
        
        Networking.sharedInstance.openNewXMLRequest(.GET, url: url, {(data: AEXMLDocument) in
            
            println("XML:", data.xmlString)
            let articles: Dictionary<String, RSSArticle> = self.xmlParser.parseArticles(data)
            
            NSNotificationCenter.defaultCenter().postNotificationName("ArticleListUpdated", object: self, userInfo: articles)
 
        })
    }
}
