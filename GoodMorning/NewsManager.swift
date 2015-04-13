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
    
    /**
    Sends a GET request for a list of RSS Feeds from the Feedly API.
    
    :param: query A optional query string to search with
    */
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
    
    /**
    Saves a valid rss feed to the our server with a GET request
    
    :param: feed The feed object to save
    */
    func saveValidFeedToServer(feed: RSSFeed) {
        let url = SERVER_ADDRESS + "/newfeed"
        
        let token = UserDefaultsManager.sharedInstance.getToken()
        let params = ["token":token, "title":feed.title, "type":feed.type.rawValue, "updated":feed.lastActiveDate.toRFC822String(), "link":feed.link, "description":feed.contentDescription, "source":feed.rssLink, "logo": feed.logoURL, "lang": feed.language]
        
        Networking.sharedInstance.openNewJSONRequest(.GET, url: url, parameters: params, completion: {(data: JSON) in
            let json = data
            var dictionary = Dictionary<String, AnyObject>()
            
            println(json)
            
            if let reason = json["reason"].string {
                if let message = json["message"].string {
                    dictionary["message"] = message
                    dictionary["reason"] = reason
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidFeedResponse, object: self, userInfo: dictionary)
                }
            }
            
            if let result = json["success"].string {
                dictionary["success"] = result.boolValue()
                NSNotificationCenter.defaultCenter().postNotificationName(kNewsAdded, object: self, userInfo: dictionary)
            }
        })
        
    }
    
    /**
    Gets a list of all the feeds from the server
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidFeedResponse, object: self, userInfo: dictionary)
                }
            }
            
            if let array = json.array {
                self.jsonParser.parseAllFeeds(json)
                return
            }
            
            println("Getting feeds on server failed because response was invalid")
        })
    }
    
    /**
    Delete an RSS Feed from the server
    
    :param: rssfeed The RSS Feed object to delete
    */
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
                    NSNotificationCenter.defaultCenter().postNotificationName(kInvalidFeedResponse, object: self, userInfo: dictionary)
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
    
    /**
    Gets a up to 12 articles from a give feed and stores them in core data for offline access
    
    :param: rssfeed An RSS Feed to get the content from
    */
    func getArticlesForFeed(rssfeed: RSSFeed) {
        let url = rssfeed.rssLink
        
        Networking.sharedInstance.openNewXMLRequest(.GET, url: url, {(data: AEXMLDocument) in
            
            CoreDataManager.sharedInstance.clearArticlesWithFeedName(rssfeed.title)
            println("XML:", data.xmlString)
            let articles: Dictionary<String, RSSArticle> = self.xmlParser.parseArticles(data)
            
            if articles.count > 12 {
                var counter: Int = 0
                let list = Array(articles.values)
                
                while(counter < 10) {       // Only store 10 stories per feed
                    CoreDataManager.sharedInstance.saveArticle(list[counter], feedname: rssfeed.title)
                    counter++
                }
            } else {
                for feed in articles.values {
                    CoreDataManager.sharedInstance.saveArticle(feed, feedname: rssfeed.title)
                }
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(kArticleListUpdated, object: self, userInfo: articles)
            
        })
    }
}
