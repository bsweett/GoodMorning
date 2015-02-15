//
//  AppDelegate.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navController : UINavigationController?
    var sound: NSURL!
    var audioPlayer: AVAudioPlayer!

    // Override point for customization after application launch.
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var initialViewController: UIViewController
        
        UIApplication.sharedApplication().keyWindow?.tintColor = gmOrangeColor
        
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge, categories: nil))
        }
        
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        
        self.sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("jungle", ofType: "wav")!)
        self.audioPlayer = AVAudioPlayer(contentsOfURL: sound, error: nil)
        
        // app already installed
        if (UserDefaultsManager.sharedInstance.getToken() != "") {
            initialViewController = storyboard.instantiateViewControllerWithIdentifier("Pager") as UIViewController
            
        } else {
            // This is the first launch ever
            initialViewController = storyboard.instantiateViewControllerWithIdentifier("Install") as UIViewController
        }
        
        let frame = UIScreen.mainScreen().bounds
        window = UIWindow(frame: frame)
        
        navController = UINavigationController(rootViewController: initialViewController)
        navController?.setNavigationBarHidden(true, animated: false)
        navController?.interactivePopGestureRecognizer.enabled = false;
        
        UIBarButtonItem.appearance().tintColor = gmOrangeColor
        UINavigationBar.appearance().tintColor = gmOrangeColor
        
        window!.rootViewController = navController
        window!.makeKeyAndVisible()
        
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
       
        LocationManager.sharedInstance.update()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
    }

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(application: UIApplication) {
        
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        println("fired")
        
        self.sound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("jungle", ofType: "wav")!)
        self.audioPlayer = AVAudioPlayer(contentsOfURL: sound, error: nil)
        audioPlayer.play()
    }
}

