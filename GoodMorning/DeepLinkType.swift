//
//  DeepLinkType.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-04-14.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

enum DeepLinkType: String {
   
    case YOUTUBE = "YouTube", MUSIC = "Music", BOOKS = "Books", MAPS = "Maps", SMS = "Messenger", FACEBOOK = "FaceBook", NONE = "None"
    
    static let allValues = [YOUTUBE, MUSIC, BOOKS, MAPS, SMS, FACEBOOK, NONE]
    static let displayValues = [YOUTUBE.rawValue, MUSIC.rawValue, MAPS.rawValue, BOOKS.rawValue, SMS.rawValue, FACEBOOK.rawValue, NONE.rawValue]
    
    static func typeFromString(string: String) -> DeepLinkType {
        switch(string) {
        case "YouTube":
            return DeepLinkType.YOUTUBE
        case "Music":
            return DeepLinkType.MUSIC
        case "Books":
            return DeepLinkType.BOOKS
        case "Maps":
            return DeepLinkType.MAPS
        case "Messenger":
            return DeepLinkType.SMS
        case "FaceBook":
            return DeepLinkType.FACEBOOK
        default:
            return DeepLinkType.NONE
        }
    }
    
    static func typeFromWebString(string: String) -> DeepLinkType {
        switch(string) {
        case "YOUTUBE":
            return DeepLinkType.YOUTUBE
        case "MUSIC":
            return DeepLinkType.MUSIC
        case "BOOKS":
            return DeepLinkType.BOOKS
        case "MAPS":
            return DeepLinkType.MAPS
        case "SMS":
            return DeepLinkType.SMS
        case "FACEBOOK":
            return DeepLinkType.FACEBOOK
        default:
            return DeepLinkType.NONE
        }
    }

}
