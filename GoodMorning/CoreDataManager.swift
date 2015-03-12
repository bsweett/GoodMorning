//
//  CoreDataManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-03-11.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
   
    class var sharedInstance : CoreDataManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : CoreDataManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = CoreDataManager()
        }
        return Static.instance!
    }
    
    //MARK: - General
    
    // NOTE: it will always return a list even if only one object (ie weather)
    func getObjectListForEntity(name: String) -> [NSManagedObject] {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: name)
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        return []
    }
    
    //NOTE: Clear all objects before writing new ones
    func clearAllObjectsInEntity(entity: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.includesPropertyValues = false
        
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            
            for object in results {
                managedContext.deleteObject(object)
            }
            
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
    }
    
    //MARK: - Articles
    
    func saveArticle(article: RSSArticle, feedname: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Articles", inManagedObjectContext: managedContext)
        let news = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
    
        news.setValue(article.title, forKey: "title")
        news.setValue(article.thumbnailURL, forKey: "thumbnailurl")
        news.setValue(article.creator, forKey: "creator")
        news.setValue(article.pubdate, forKey: "pubdate")
        news.setValue(article.link, forKey: "link")
        news.setValue(article.textDescription, forKey: "content")
        news.setValue(feedname, forKey: "feed")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    

    
    //MARK: - Alarms
    
    func saveAlarm(alarm: Task) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Alarms", inManagedObjectContext: managedContext)
        let alarms = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        alarms.setValue(alarm.id, forKey: "id")
        alarms.setValue(alarm.title, forKey: "title")
        alarms.setValue(alarm.type.rawValue, forKey: "type")
        alarms.setValue(alarm.alertTime, forKey: "time")
        alarms.setValue(alarm.soundFileName, forKey: "soundfilename")
        alarms.setValue(alarm.creationDate, forKey: "creation")
        alarms.setValue(alarm.nextAlertDate, forKey: "nextdate")
        alarms.setValue(alarm.mon, forKey: "mon")
        alarms.setValue(alarm.tue, forKey: "tue")
        alarms.setValue(alarm.wed, forKey: "wed")
        alarms.setValue(alarm.thu, forKey: "thu")
        alarms.setValue(alarm.fri, forKey: "fri")
        alarms.setValue(alarm.sat, forKey: "sat")
        alarms.setValue(alarm.sun, forKey: "sun")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    //MARK: - Weather
    
    func saveWeather(weather: Weather) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Weather", inManagedObjectContext: managedContext)
        let weathers = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        weathers.setValue(weather.temperature, forKey: "temperature")
        weathers.setValue(weather.nighttime, forKey: "nighttime")
        weathers.setValue(weather.city, forKey: "city")
        weathers.setValue(weather.country, forKey: "country")
        weathers.setValue(weather.time, forKey: "time")
        weathers.setValue(weather.icon, forKey: "icon")
        weathers.setValue(weather.condition, forKey: "condition")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
}
