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
        
        var notification = UILocalNotification()
        notification.fireDate = task.nextAlertDate
        notification.alertBody = task.title
        notification.soundName = UILocalNotificationDefaultSoundName
        
        notification.applicationIconBadgeNumber = unreadNotifCount
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
}
