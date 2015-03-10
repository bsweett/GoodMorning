//
//  RSSType.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-15.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

enum RSSType: String {
    case NEWS = "News", BUSINESS = "Business", SCIENCE = "Science", TECHNOLOGY = "Technology",
    SPORTS = "Sports", LIFESTYLE = "Lifestyle", ENTERTAINMENT = "Entertainment", OTHER = ""
    
    static let allValues = [NEWS, BUSINESS, SCIENCE, TECHNOLOGY, SPORTS, LIFESTYLE, ENTERTAINMENT, OTHER]
    static let displayValues = [NEWS.rawValue, BUSINESS.rawValue, SCIENCE.rawValue, TECHNOLOGY.rawValue, SPORTS.rawValue, LIFESTYLE.rawValue, ENTERTAINMENT.rawValue]
    
    static func typeFromString(string: String) -> RSSType {
        switch(string.lowercaseString) {
        case "news":
            return RSSType.NEWS
        case "business":
            return RSSType.BUSINESS
        case "science":
            return RSSType.SCIENCE
        case "technology":
            return RSSType.TECHNOLOGY
        case "sports":
            return RSSType.SPORTS
        case "lifestyle":
            return RSSType.LIFESTYLE
        case "entertainment":
            return RSSType.ENTERTAINMENT
        default:
            return RSSType.OTHER
        }
    }
}