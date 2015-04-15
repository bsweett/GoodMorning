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
    
    var hubController: UIViewController? = nil
    var newsController: UIViewController? = nil
    var weatherController: UIViewController? = nil
    var tasksController: UIViewController? = nil
    
    var currentViewController: UIViewController? = nil
    
    func getHub() -> UIViewController? {
        
        if(hubController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let hubVC = sb.instantiateViewControllerWithIdentifier("Hub") as? HubViewController
            self.hubController = hubVC
        }
        
        return self.hubController
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
        
        self.setViewControllers([self.getHub()!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.navigationItem.title = "Hub"
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"gm_settings"), style: .Bordered, target: self, action: Selector("settingsTapped:"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"gm_refresh"), style: .Bordered, target: self.getHub(), action: Selector("refreshTapped:"))
        
        self.currentViewController = self.getHub()!
        
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
        appearance.backgroundColor = gmOrangeColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var previousViewController: UIViewController? = nil
        
        if(viewController == self.getHub()) {
            previousViewController = self.getTasks()
        }
        if (viewController == self.getTasks()) {
            previousViewController = self.getNews();
        }
        if (viewController == self.getNews()) {
            previousViewController = self.getWeather();
        }
        if (viewController == self.getWeather()) {
            previousViewController = self.getHub();
        }
        
        return previousViewController
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var nextViewController: UIViewController? = nil
        
        if (viewController == self.getHub()) {
            nextViewController = self.getWeather()
        }
        if (viewController == self.getWeather()) {
            nextViewController = self.getNews()
        }
        if (viewController == self.getNews()) {
            nextViewController = self.getTasks()
        }
        if (viewController == self.getTasks()) {
            nextViewController = self.getHub()
        }
        
        return nextViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        
        if let current = pageViewController.viewControllers[0] as? UIViewController {
            if(current == self.getHub()) {
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
            
            if(current == self.getHub()) {
                var refreshButton = UIBarButtonItem(image: UIImage(named:"gm_refresh"), style: .Bordered, target: self.getHub(), action: Selector("refreshTapped:"))
                self.navigationItem.rightBarButtonItem = refreshButton
            }
            
            if(current == self.getWeather()) {
                var refreshButton = UIBarButtonItem(image: UIImage(named:"gm_refresh"), style: .Bordered, target: self.getWeather(), action: Selector("refreshTapped:"))
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
        if( ios8() ) {
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        }
    }
    
}
