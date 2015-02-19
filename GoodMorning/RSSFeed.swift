//
//  RSSFeed.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-15.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class RSSFeed: NSObject {
   
    var id: String
    var title: String
    var link: String
    var contentDescription: String
    var language: String
    var type: RSSType
    
    var creationDate: NSDate
    var lastActiveDate: NSDate
    
    var logoURL: String!
    var rssLink: String!

    // From existing JSON
    init(id: String, title: String, creation: NSDate, lastActiveDate: NSDate, type: RSSType, description: String, language: String, link: String, rssLink: String) {
        
        self.id = id
        self.title = title
        self.creationDate = creation
        self.lastActiveDate = lastActiveDate
        self.type = type
        self.language = language
        self.link = link
        self.contentDescription = description
        self.rssLink = rssLink
    }
    
    // From existing JSON
    init(title: String, creation: NSDate, lastActiveDate: NSDate, type: RSSType, description: String, language: String, link: String, rssLink: String) {
        
        self.id = ""
        self.title = title
        self.creationDate = creation
        self.lastActiveDate = lastActiveDate
        self.type = type
        self.language = language
        self.link = link
        self.contentDescription = description
        self.rssLink = rssLink
        
    }
    
    func linkAsUrl() -> NSURL {
        return NSURL(string: self.link)!
    }
    
    func setLogoUrl(url: String) {
        self.logoURL = url
    }
    
    func toString() -> String {
        return "Title: " + self.title +
            " Link: " + self.link +
            " Description: " + self.contentDescription +
            " Language: " + self.language +
            " Type: " + self.type.rawValue +
            " created: " + self.creationDate.toTimeString() +
            " active: " + self.lastActiveDate.toTimeString() +
            " logoURL: " + self.logoURL +
            " rssLink: " + self.rssLink
    }
}
