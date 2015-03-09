//
//  NotificationManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-03.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit

class NotificationManager {
   
    //Creating Singleton instance of the class
    class var sharedInstance: NotificationManager {
        struct Static {
            static var instance: NotificationManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = NotificationManager()
        }
        
        return Static.instance!
    }
    
    var unreadNotifCount = 0
    
    func scheduleNotificationForTask(task: Task) {
        unreadNotifCount++
        
        //notificationTest(task)
        
        if(task.isEveryDayRepeated()) {
            scheduleNotificationForEveryDay(task)
            
        } else if(!task.isNeverRepeated()) {
            scheduleNotificationsForCustomDays(task)
            
        } else {
            scheduleNotificationForOnce(task)
            
        }
    }
    
    private func notificationTest(task: Task) {
        var notes: String = ""
        task.notes.isEmpty ? (notes = "") : (notes = " - " + task.notes)
        
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.fireDate = NSDate().addMinutesToDate(1)
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    private func scheduleNotificationForEveryDay(task: Task) {
        
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.fireDate = task.nextAlertDate
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.repeatInterval = NSCalendarUnit.DayCalendarUnit
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    private func scheduleNotificationForOnce(task: Task) {
  
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.fireDate = task.nextAlertDate
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    private func scheduleNotificationsForCustomDays(task: Task) {
        
        if task.sun {
            scheduleNotificationsForDayWeekly(task, date: getDateOfSpecificDay(1))
        }
        
        if task.mon {
            scheduleNotificationsForDayWeekly(task, date: getDateOfSpecificDay(2))
        }
        
        if task.tue {
            scheduleNotificationsForDayWeekly(task, date: getDateOfSpecificDay(3))
        }
        
        if task.wed {
            scheduleNotificationsForDayWeekly(task, date: getDateOfSpecificDay(4))
        }
        
        if task.thu {
            scheduleNotificationsForDayWeekly(task, date: getDateOfSpecificDay(5))
        }
        
        if task.fri {
            scheduleNotificationsForDayWeekly(task, date: getDateOfSpecificDay(6))
        }
        
        if task.sat {
            scheduleNotificationsForDayWeekly(task, date: getDateOfSpecificDay(7))
        }
        
    }
    
    private func scheduleNotificationsForDayWeekly(task: Task, date: NSDate) {
        
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.fireDate = date
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.repeatInterval = NSCalendarUnit.WeekCalendarUnit
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    // 1 sunday ... 7 saturday
    private func getDateOfSpecificDay(day: Int) -> NSDate {
        var range = NSCalendar.currentCalendar().maximumRangeOfUnit(NSCalendarUnit.WeekdayCalendarUnit)
        var daysInWeek = range.length - range.location + 1
        
        var dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.WeekdayCalendarUnit, fromDate:NSDate());
        var currentWeekday = dateComponents.weekday;
        var differenceDays = (day - currentWeekday + daysInWeek) % daysInWeek;
        var daysComponents = NSDateComponents()
        daysComponents.day = differenceDays
        var resultDate = NSCalendar.currentCalendar().dateByAddingComponents(daysComponents, toDate: NSDate(), options: NSCalendarOptions.allZeros)
        return resultDate!
    }
    
    func updateNotificationForTask(task: Task) {
        cancelNotificationsForTask(task)
        scheduleNotificationForTask(task)
    }
    
    func cancelNotificationsForTask(task: Task) {
        
        var app: UIApplication = UIApplication.sharedApplication()
        for oneEvent in app.scheduledLocalNotifications {
            var notification = oneEvent as UILocalNotification
            let userInfoCurrent = notification.userInfo! as Dictionary<String, String>
            
            let uid = userInfoCurrent["id"]! as String
            if uid == task.id {
                //Cancelling local notification
                NSLog("Removing notification with id: ", uid)
                app.cancelLocalNotification(notification)
            }
        }
        
    }
}
