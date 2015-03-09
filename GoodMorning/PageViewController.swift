//
//  PageViewController.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-23.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation
import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var alarmController: UIViewController? = nil
    var newsController: UIViewController? = nil
    var weatherController: UIViewController? = nil
    var tasksController: UIViewController? = nil
    
    var currentViewController: UIViewController? = nil
    
    func getAlarm() -> UIViewController? {
        
        if(alarmController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let alarmVC = sb.instantiateViewControllerWithIdentifier("Alarms") as? AlarmsViewController
            self.alarmController = alarmVC
        }
        
        return self.alarmController
    }
    
    func getNews() -> UIViewController? {
        
        if(newsController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.newsController = sb.instantiateViewControllerWithIdentifier("News") as? UIViewController
        }
        
        return self.newsController
    }
    
    func getWeather() -> UIViewController? {
        
        if(weatherController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.weatherController = sb.instantiateViewControllerWithIdentifier("Weather") as? UIViewController
        }
        
        return self.weatherController
    }
    
    func getTasks() -> UIViewController? {
        
        if(tasksController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.tasksController = sb.instantiateViewControllerWithIdentifier("Tasks") as? UIViewController
        }
        
        return self.tasksController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        self.setViewControllers([self.getAlarm()!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.navigationItem.title = "Alarms"
        self.navigationItem.rightBarButtonItem = nil
        self.navigationController?.navigationBar.backgroundColor = gmBlueColor
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"configuration12.png"), style: .Bordered, target: self, action: Selector("settingsTapped:"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"circular194.png"), style: .Bordered, target: self.getAlarm(), action: Selector("refreshTapped:"))
        
        self.currentViewController = self.getAlarm()!
        
        self.setPageControl()
        
    }
    
    func displayTasksView() {
        self.setViewControllers([self.getTasks()!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
    }
    
    func setPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.whiteColor()
        appearance.currentPageIndicatorTintColor = UIColor.blackColor()
        appearance.numberOfPages = 4
        appearance.backgroundColor = gmOrangeColor //UIColor(red: (247/255.0), green: (247/255.0), blue: (247/255.0), alpha: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var previousViewController: UIViewController? = nil
        
        if(viewController == self.getAlarm()) {
            previousViewController = self.getTasks()
        }
        if (viewController == self.getTasks()) {
            previousViewController = self.getNews();
        }
        if (viewController == self.getNews()) {
            previousViewController = self.getWeather();
        }
        if (viewController == self.getWeather()) {
            previousViewController = self.getAlarm();
        }
        
        return previousViewController
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var nextViewController: UIViewController? = nil
        
        if (viewController == self.getAlarm()) {
            nextViewController = self.getWeather()
        }
        if (viewController == self.getWeather()) {
            nextViewController = self.getNews()
        }
        if (viewController == self.getNews()) {
            nextViewController = self.getTasks()
        }
        if (viewController == self.getTasks()) {
            nextViewController = self.getAlarm()
        }
        
        return nextViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        if let current = pageViewController.viewControllers[0] as? UIViewController {
            if(current == self.getAlarm()) {
                return 0
            }
            
            if(current == self.getWeather()) {
                return 1
            }
            
            if(current == self.getNews()) {
                return 2
            }
            
            if(current == self.getTasks()) {
                return 3
            }
        }
        
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        
        if let current = pageViewController.viewControllers[0] as? UIViewController {
            
            if(current == self.getAlarm()) {
                var refreshButton = UIBarButtonItem(image: UIImage(named:"circular194.png"), style: .Bordered, target: self.getAlarm(), action: Selector("refreshTapped:"))
                self.navigationItem.rightBarButtonItem = refreshButton
            }
            
            if(current == self.getWeather()) {
                var refreshButton = UIBarButtonItem(image: UIImage(named:"circular194.png"), style: .Bordered, target: self.getWeather(), action: Selector("refreshTapped:"))
                self.navigationItem.rightBarButtonItem = refreshButton
            }
            
            if(current == self.getNews()) {
                var addButton = UIBarButtonItem(image: UIImage(named:"add121.png"), style: .Bordered, target: self.getNews(), action: Selector("addNewRSSFeed:"))
                self.navigationItem.rightBarButtonItem = addButton
            }
            
            if(current == self.getTasks()) {
                var addButton = UIBarButtonItem(image: UIImage(named:"add121.png"), style: .Bordered, target: self.getTasks(), action: Selector("addNewTask:"))
                self.navigationItem.rightBarButtonItem = addButton
            }
        }
    }
    
    @IBAction func settingsTapped(sender: UIBarButtonItem) {
        // only supported in iOS8
        if( ios8() ) {
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        }
    }
    
}
