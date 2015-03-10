//
//  RSSArticle.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-24.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class RSSArticle: NSObject {
   
    var title: String!
    var link: String!
    var pubdate: NSDate!
    var creator: String!
    var categories: [String]!
    var thumbnailURL: String
    var rawDescription: String!
    var textDescription: String!
    var image: UIImage!
    
    override init() {
        self.title = ""
        self.link = ""
        self.pubdate = NSDate()
        self.creator = ""
        self.categories = []
        self.thumbnailURL = ""
        self.rawDescription = ""
        self.textDescription = ""
        self.image = nil
        super.init()
    }
    
    func linkAsURL() -> NSURL {
        return  NSURL(string: self.link)!
    }
    
    func thumbnailAsURL() -> NSURL {
        return NSURL(string: self.thumbnailURL)!
    }
    
    func addCategory(category: String) {
        self.categories.append(category)
    }
    
    func toString() -> String {
        return "Title: " + self.title +
            " Link: " + self.link +
            " Description: " + self.textDescription +
            " Image Url: " + self.thumbnailURL +
            " Creator: " + self.creator +
            " pub date: " + self.pubdate.toFullDateString()
    }
}
