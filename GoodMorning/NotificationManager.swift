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
    
    // The unread notification count to display as a badge
    var unreadNotifCount = 0
    
    /**
    Schedules a notificaiton for a given task
    
    :param: task The task object to schedule the notification from
    */
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
    
    /**
    A notification testing function. Used only for testing and development
    
    :param: task A task to test a notifiction scheduling
    */
    private func notificationTest(task: Task) {
        var notes: String = ""
        task.notes.isEmpty ? (notes = "") : (notes = " - " + task.notes)
        
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.timeZone = NSTimeZone(abbreviation: "EST")
        notification.fireDate = NSDate().addMinutesToDate(1)
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /**
    Schedules a notification the repeats at the same time everyday
    
    :param: task A task to schedule
    */
    private func scheduleNotificationForEveryDay(task: Task) {
        
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.timeZone = NSTimeZone(abbreviation: "EST")
        notification.fireDate = task.nextAlertDate
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.repeatInterval = NSCalendarUnit.DayCalendarUnit
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /**
    Schedules a notification that fires once and never repeats
    
    :param: task A task to schedule
    */
    private func scheduleNotificationForOnce(task: Task) {
  
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.timeZone = NSTimeZone(abbreviation: "EST")
        notification.fireDate = task.nextAlertDate
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /**
    Schedules a notification that fires on specific days
    
    :param: task A task to schedule
    */
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
    
    /**
    Schedules a notification that fires on a given date
    
    :param: task A task to schedule
    :param: date A date to fire it on
    */
    private func scheduleNotificationsForDayWeekly(task: Task, date: NSDate) {
        
        var notification = UILocalNotification()
        notification.userInfo = ["id": task.id]
        notification.timeZone = NSTimeZone(abbreviation: "EST")
        notification.fireDate = date
        notification.alertBody = task.getNotifBody()
        notification.applicationIconBadgeNumber = unreadNotifCount
        notification.repeatInterval = NSCalendarUnit.WeekCalendarUnit
        notification.soundName = task.getSoundFileNameForPlayback()
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /**
    Gets a specific date based on the day of the week given (1 - 7, Sunday - Saturday)
    
    :param: day A number between 1 - 7 to get the date
    
    :returns: the next date that matches the day of the week
    */
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
    
    /**
    Updates the notifications that are already scheduled for a given task
    
    :param: task The task to update the notifications for
    */
    func updateNotificationForTask(task: Task) {
        cancelNotificationsForTask(task)
        scheduleNotificationForTask(task)
    }
    
    /**
    Gets a list of notifications based on a given task
    
    :param: task The task to get the notifcations of
    
    :returns: A list of LocalNotifications
    */
    func findNotificationsForTask(task: Task) -> [UILocalNotification] {
        var list = [UILocalNotification]()
        
        var app: UIApplication = UIApplication.sharedApplication()
        for oneEvent in app.scheduledLocalNotifications {
            var notification = oneEvent as UILocalNotification
            let userInfoCurrent = notification.userInfo! as Dictionary<String, String>
            
            let uid = userInfoCurrent["id"]! as String
            if uid == task.id {
                list.append(notification)
            }
        }
        
        return list
    }
    
    /**
    Cancels all active notifications for a given task
    
    :param: task The task to cancel notifications of
    */
    func cancelNotificationsForTask(task: Task) {
        
        var app: UIApplication = UIApplication.sharedApplication()
        for oneEvent in app.scheduledLocalNotifications {
            var notification = oneEvent as UILocalNotification
            let userInfoCurrent = notification.userInfo! as Dictionary<String, String>
            
            let uid = userInfoCurrent["id"]! as String
            if uid == task.id {
                //Cancelling local notification
                NSLog("Removing notification with id: %@", uid)
                app.cancelLocalNotification(notification)
            }
        }
        
    }
}
