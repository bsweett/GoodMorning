//
//  GMConstants.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-18.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

let ipHome1 = "http://192.168.1.101:8080"
let ipHome4 = "http://192.168.1.104:8080"
let ipHome5 = "http://192.168.1.105:8080"
let ipHome7 = "http://192.168.1.107:8080"
let ipOak = "http://192.168.1.14:8080"
let ipHome237 = "http://192.168.1.237:8080"
let amazonEC2 = "http://ec2-54-149-69-85.us-west-2.compute.amazonaws.com:8080"

let SERVER_ADDRESS = ipHome237 + "/GoodMorning-Server"
let FEEDLY_ADDRESS = "https://cloud.feedly.com/v3/"
let WEATHER_ADDRESS = "http://api.openweathermap.org/data/2.5/forecast"

// UserDefault Keys
let udEmailID: String = "EMAILUD"
let udToken: String = "TOKENUD"
let udUserID: String = "USERIDUD"
let udUserName: String = "USERNAMEUD"
let udLastActive: String = "LASTACTIVEUD"
let udCreated: String = "CREATEDUD"
let udNight: String = "NIGHTUD"

// Colors
let gmOrangeColor: UIColor = UIColor(red: (243/255.0), green: (156/255.0), blue: (18/255.0), alpha: 1.0)
let gmYellowColor: UIColor = UIColor(red: (225/255.0), green: (222/255.0), blue: (0/255.0), alpha: 1.0)
let gmLightBlueColor: UIColor = UIColor(red: (0/255.0), green: (89/255.0), blue: (166/255.0), alpha: 0.8)

// Numbers
let radius: CGFloat = 12

// Font
let gmFontQuote: UIFont = UIFont(name: "Avenir-MediumOblique", size: 15)!
let gmFontQuoteLarge: UIFont = UIFont(name: "Avenir-MediumOblique", size: 17)!
let gmFontNormal: UIFont = UIFont(name: "Avenir-Medium", size: 17)!
let gmFontBold: UIFont = UIFont(name: "Avenir-Heavy", size: 18)!

// Notifications
let kNetworkError = "NetworkError"
let kInternalServerError = "InternalServerError"

let kInvalidTaskRespone = "InvalidTaskResponse"
let kTaskAdded = "TaskAdded"
let kTaskUpdated = "TaskUpdated"
let kTaskListUpdated = "TaskListUpdated"
let kAlarmListUpdated = "AlarmListUpdated"

let kInvalidFeedResponse = "InvalidFeedResponse"
let kFeedListUpdated = "FeedListUpdated"
let kNewsAdded = "NewsAdded"
let kArticleListUpdated = "ArticleListUpdated"

let kInvalidInstallResponse = "InvalidInstallResponse"
let kSafeToInstall = "SafeToInstall"

let kLocationDisabled = "LocationDisabled"
let kLocationDenied = "LocationDenied"
let kLocationUnknown = "LocationUnknown"

let kWeatherUpdated = "WeatherUpdated"
let kNightCachedChanged = "NightCachedChanged"