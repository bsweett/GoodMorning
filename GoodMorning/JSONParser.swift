//
//  JSONParser.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-07.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit
import Foundation

class JSONParser: NSObject {
    
    var dateFormatter: NSDateFormatter!
    
    override init() {
        super.init()
        dateFormatter = NSDateFormatter()
        
        //Jan 9, 2015 6:52:14 PM
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
    }
    
    //MARK: - User JSON
    
    /**
    Parses JSON and sends a notification for a clean installation from a new user account
    
    :param: userData JSON from the server of a user
    */
    func parseInstallUserData(userData: JSON) {
        let user: User = self.parseUserJSON(userData)
        let dictionary = ["user": user]
        NSNotificationCenter.defaultCenter().postNotificationName("InstallComplete", object: self, userInfo: dictionary)
    }
    
    func parseExistingUserData(userData: JSON) {
        let user: User = self.parseUserJSON(userData)
        let dictionary = ["user": user]
        NSNotificationCenter.defaultCenter().postNotificationName("ExistingAccountFound", object: self, userInfo: dictionary)
    }
    
    private func parseUserJSON(userData: JSON) -> User {
        let tempDate: NSDate = NSDate()
        
        let userId: String = userData["userId"].string!
        let deviceId: String = userData["deviceId"].string!
        let token: String = userData["userToken"].string!
        let nickname: String = userData["nickname"].string!
        let email: String = userData["email"].string!
        let creationString: String = userData["creationDate"].string!
        let lastActiveString: String = userData["lastActive"].string!
        
        let creationDate: NSDate = dateFormatter.dateFromString(creationString)!
        let lastActiveDate: NSDate = dateFormatter.dateFromString(lastActiveString)!
        
        var user: User = User(id: userId, token: token, email: email, name: nickname, creation: creationDate, lastActive: lastActiveDate)
        
        // TODO: Pass feeds to user object constructor
        if let list: Array<JSON> = userData["rssFeeds"].array {
            
            
        }
        
        //If not a Array or nil, return []
        if let list: Array<JSON> = userData["taskSet"].array {
            
            for task in list {
                let taskId = task["taskId"].string!
                let taskName = task["name"].string!
                let taskTypeString = task["taskType"].string!
                let taskCreateString = task["creationTimestamp"].string!
                let taskNextAlertString = task["nextAlertTimestamp"].string!
                let taskAlertTimeString = task["alertTime"].string!
                let soundEnabled = task["soundFileName"].string!
                let notes = task["Notes"].string!
                
                let monday = task["monday"].boolValue
                let tuesday = task["tuesday"].boolValue
                let wednesday = task["wednesday"].boolValue
                let thursday = task["thursday"].boolValue
                let friday = task["friday"].boolValue
                let saturday = task["saturday"].boolValue
                let sunday = task["sunday"].boolValue
                
                let tType = TaskType.typeFromString(taskTypeString)
                
                let taskCreateDate: NSDate = dateFormatter.dateFromString(taskCreateString)!
                let taskNexAlertDate: NSDate = dateFormatter.dateFromString(taskNextAlertString)!
                
                var task: Task = Task(id: taskId, title: taskName, creation: taskCreateDate, nextAlert: taskNexAlertDate, type: tType, alertTime: taskAlertTimeString, soundFileName: soundEnabled, notes: notes)
                task.setDaysOfTheWeek(monday, tue: tuesday, wed: wednesday, thu: thursday, fri: friday, sat: saturday, sun: sunday)
                user.addTask(task)
            }
        }
        
        return user
    }
    
    //MARK: - Task JSON
    
    func parseAllTasks(taskData: JSON) {
        let taskList: Dictionary<String, Task>! = parseTaskList(taskData)
        NSNotificationCenter.defaultCenter().postNotificationName("TaskListUpdated", object: self, userInfo: taskList)
    }
    
    func parseAlarmTasks(taskData: JSON) {
        CoreDataManager.sharedInstance.clearAllObjectsInEntity("Alarms")
        let taskList: Dictionary<String, Task>! = parseTaskList(taskData)
        
        for alarm in taskList.values {
            CoreDataManager.sharedInstance.saveAlarm(alarm)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("AlarmListUpdated", object: self, userInfo: taskList)
    }
    
    private func parseTaskList(taskData: JSON) -> Dictionary<String, Task> {
        
        let tempDate: NSDate = NSDate()
        var taskList: Dictionary<String, Task>! = [:]
        
        if let list: Array<JSON> = taskData.array {
            
            for task in list {
                let taskId = task["taskId"].string!
                let taskName = task["name"].string!
                let taskTypeString = task["taskType"].string!
                let taskCreateString = task["creationTimestamp"].string!
                let taskNextAlertString = task["nextAlertTimestamp"].string!
                let taskAlertTimeString = task["alertTime"].string!
                let soundEnabled = task["soundFileName"].string!
                let notes = task["Notes"].string!
                
                let monday = task["monday"].boolValue
                let tuesday = task["tuesday"].boolValue
                let wednesday = task["wednesday"].boolValue
                let thursday = task["thursday"].boolValue
                let friday = task["friday"].boolValue
                let saturday = task["saturday"].boolValue
                let sunday = task["sunday"].boolValue
                
                let tType = TaskType.typeFromString(taskTypeString)
                
                let taskCreateDate: NSDate = dateFormatter.dateFromString(taskCreateString)!
                let taskNexAlertDate: NSDate = dateFormatter.dateFromString(taskNextAlertString)!
                
                var task: Task = Task(id: taskId, title: taskName, creation: taskCreateDate, nextAlert: taskNexAlertDate, type: tType, alertTime: taskAlertTimeString, soundFileName: soundEnabled, notes: notes)
                task.setDaysOfTheWeek(monday, tue: tuesday, wed: wednesday, thu: thursday, fri: friday, sat: saturday, sun: sunday)
                taskList[task.title] = task
            }
        }
        
        return taskList
    }
    
    //MARK: - Feed JSON
    
    func parseFeedlyFeeds(feedData: [JSON], query: String) {
        var resultList: Dictionary<String, RSSFeed>! = [:]
        
        for feed in feedData {
            
            var iconUrl = ""
            var description = ""
            
            let feedUrl = feed["feedId"].string!
            let language = feed["language"].string!
            let title = feed["title"].string!
            let lastUpdateFloatingNumber = feed["lastUpdated"].number!
            let website = feed["website"].string!
            if let descr = feed["description"].string {
                description = descr
            }
            
            if let icon = feed["visualUrl"].string {        //iconUrl is very small use visual
                iconUrl = icon
            } else if let small = feed["iconUrl"].string {
                iconUrl = small
            }
            
            let type = RSSType.typeFromString(query)
            let now = NSDate()

            //NOTE: thier unix epoch time returns a correct date with online tools but the swift
            // time interval since 1970 doesn't seem to like the extra 0s. Simply and very dirty solution 
            // is to remove the last 3 zeros
            
            let strProper = lastUpdateFloatingNumber.stringValue.removeCharsFromEnd(3)
            var lastUpdated = NSDate(timeIntervalSince1970: (strProper as NSString).doubleValue)
            
            let rssLink = feedUrl.stringByReplacingOccurrencesOfString("feed/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var rss: RSSFeed = RSSFeed(title: title, creation: now, lastActiveDate: lastUpdated, type: type, description: description, language: language, link: website, rssLink: rssLink)
            rss.logoURL = iconUrl
            
            resultList[rss.title] = rss
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("FeedlyResultsFound", object: self, userInfo: resultList)
    }
    
    func parseAllFeeds(feedData: JSON) {
        let feedList: Dictionary<String, RSSFeed>! = parseFeedList(feedData)
        NSNotificationCenter.defaultCenter().postNotificationName("FeedListUpdated", object: self, userInfo: feedList)
    }
    
    private func parseFeedList(feedData: JSON) -> Dictionary<String, RSSFeed> {
        var feedList: Dictionary<String, RSSFeed>! = [:]
        
        if let list: Array<JSON> = feedData.array {
            
            for feed in list {
                
                let feedId = feed["feedId"].string!
                let title = feed["title"].string!
                let link = feed["link"].string!
                let logoUrl = feed["logoUrl"].string!
                let description = feed["description"].string!
                let language = feed["language"].string!
                let rssLink = feed["source"].string!
                let feedCreateString = feed["creationTimestamp"].string!
                let feedUpdatedString = feed["pubDate"].string!
                let feedTypeString = feed["type"].string!
                
                let fType = RSSType.typeFromString(feedTypeString)
                
                let feedCreateDate: NSDate = dateFormatter.dateFromString(feedCreateString)!
                let feedUpdatedDate: NSDate = dateFormatter.dateFromString(feedUpdatedString)!
                
                var feed: RSSFeed = RSSFeed(id: feedId, title: title, creation: feedCreateDate, lastActiveDate: feedUpdatedDate, type: fType, description: description, language: language, link: link, rssLink: rssLink)
                feed.logoURL = logoUrl
                
                feedList[feed.title] = feed
            }
            
        }
        
        return feedList
    }
    
}
