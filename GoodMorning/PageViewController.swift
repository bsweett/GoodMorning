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
            self.alarmController = sb.instantiateViewControllerWithIdentifier("Alarms") as? UIViewController
        }
        
        //self.parentViewController?.
        return self.alarmController
    }
    
    func getNews() -> UIViewController? {
        
        if(newsController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.newsController = sb.instantiateViewControllerWithIdentifier("News") as? UIViewController
        }
        
        self.parentViewController?.navigationItem.title = "News"
        return self.newsController
    }
    
    func getWeather() -> UIViewController? {
        
        if(weatherController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.weatherController = sb.instantiateViewControllerWithIdentifier("Weather") as? UIViewController
        }
        
        self.parentViewController?.navigationItem.title = "Weather"
        return self.weatherController
    }
    
    func getTasks() -> UIViewController? {
        
        if(tasksController == nil) {
            let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.tasksController = sb.instantiateViewControllerWithIdentifier("Tasks") as? UIViewController
        }
        
        self.parentViewController?.navigationItem.title = "Tasks"
        return self.tasksController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        self.setViewControllers([self.getAlarm()!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.currentViewController = self.getAlarm()!
        
        self.setPageControl()
    }
    
    // Brings page control to front of view
    //[self.view bringSubviewToFront:self.pageControl];

    // TODO: Might have to remove this and add our own because clear doesnt work
    func setPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.orangeColor()
        appearance.numberOfPages = 4
        appearance.backgroundColor = UIColor(red: (247/255.0), green: (247/255.0), blue: (247/255.0), alpha: 1)
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
    
}
