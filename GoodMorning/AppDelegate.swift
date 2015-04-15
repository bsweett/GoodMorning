//
//  AppDelegate.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var navController : UINavigationController?
    
    // Override point for customization after application launch.
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController: UIViewController
        
        UIApplication.sharedApplication().keyWindow?.tintColor = gmOrangeColor
        
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        }
        
        // app already installed
        if (UserDefaultsManager.sharedInstance.getToken() != "") {
            initialViewController = storyboard.instantiateViewControllerWithIdentifier("Pager") as UIViewController
            
            let date = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
            let hour = components.hour
            let minutes = components.minute
            
            var timeOfDaySpeech = "Good Morning "
            if(hour > 12 && hour < 18) {
                timeOfDaySpeech = "Good Afternoon "
            }
            
            if(hour >= 18) {
                timeOfDaySpeech = "Good Evening "
            }
            
            var speech = TextToSpeech()
            speech.speak(timeOfDaySpeech + UserDefaultsManager.sharedInstance.getUserName())
        } else {
            // This is the first launch ever
            initialViewController = storyboard.instantiateViewControllerWithIdentifier("Install") as UIViewController
        }
        
        let frame = UIScreen.mainScreen().bounds
        window = UIWindow(frame: frame)
        
        navController = UINavigationController(rootViewController: initialViewController)
        navController?.setNavigationBarHidden(true, animated: false)
        navController?.interactivePopGestureRecognizer.enabled = false;
        
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = gmOrangeColor
        UINavigationBar.appearance().translucent = false
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: gmFontBold]
        
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        
        UIToolbar.appearance().barTintColor = gmOrangeColor
        UIToolbar.appearance().backgroundColor = gmOrangeColor
        UIToolbar.appearance().translucent = false
        
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
        
        
        let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as UILocalNotification!
        if (notification != nil) {
            if let userInfoCurrent = notification.userInfo! as? Dictionary<String, String> {
                let title = userInfoCurrent["task"]!
                let linkType = DeepLinkType.typeFromString(userInfoCurrent["link"]!)
                
                if linkType != DeepLinkType.NONE {
                    
                    let alert = SCLAlertView()
                    alert.addButton("Lanuch App") {
                        self.handleTaskNotification(title, link: linkType)
                    }
                    
                    alert.addButton("Ignore") {
                        
                    }
                    
                    alert.showInfo("Unlaunched App", subTitle: "A unread task has occured that wants to launch another app.")
                }
            }
            
        }
        
        return true
    }
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    func applicationWillResignActive(application: UIApplication) {
        
        LocationManager.sharedInstance.stopUpdate()
        /*
        var timer = NSTimer(fireDate: NSDate(timeIntervalSinceNow: 20), interval: 60.0, target: self, selector: Selector("playAlarm"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)*/
        
    }
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    func applicationWillEnterForeground(application: UIApplication) {
        
        
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    func applicationDidBecomeActive(application: UIApplication) {
        
        //LocationManager.sharedInstance.update()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        if (UserDefaultsManager.sharedInstance.getToken() != "") {
            UserDefaultsManager.sharedInstance.updateLastActiveRecord()
        }
    }
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Local Notification Handlers
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let userInfoCurrent = notification.userInfo! as? Dictionary<String, String> {
            let title = userInfoCurrent["task"]!
            let linkType = DeepLinkType.typeFromString(userInfoCurrent["link"]!)
            handleTaskNotification(title, link: linkType)
        }
    }
    
    private func handleTaskNotification(title: String, link: DeepLinkType) {
            var speech = TextToSpeech()
            speech.speak(title)
        
            var linkString = ""
            
            switch(link) {
            case DeepLinkType.YOUTUBE:
                linkString = "youtube://"
                break
            case DeepLinkType.FACEBOOK:
                linkString = "fb://feed"
                break
            case DeepLinkType.MUSIC:
                linkString = "music://"
                break
            case DeepLinkType.MAPS:
                linkString = "maps://"
                break
            case DeepLinkType.BOOKS:
                linkString = "itms-books://"
                break
            case DeepLinkType.SMS:
                linkString = "sms://"
                break
            default:
                return
            }
            
            var url = NSURL(string: linkString)!
            if (UIApplication.sharedApplication().canOpenURL(url)) {
                UIApplication.sharedApplication().openURL(url)
            }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {

    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Carleton.Test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        //let modelURL = NSBundle.mainBundle().URLForResource("GoodMorning", withExtension: "momd")!
        return NSManagedObjectModel.mergedModelFromBundles(nil)! //(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("GoodMorning.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
}

