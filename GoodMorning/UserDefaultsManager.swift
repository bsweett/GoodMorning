//
//  ApplicationDataManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-12.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    var userDefaults: NSUserDefaults
    private var dateFormatter: NSDateFormatter = NSDateFormatter()
    
    //Creating Singleton instance of the class
    class var sharedInstance: UserDefaultsManager {
        struct Static {
            static var instance: UserDefaultsManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = UserDefaultsManager()
        }
        
        return Static.instance!
    }
    
    //Initializer
    init() {
        userDefaults = NSUserDefaults.standardUserDefaults()
    }
    
    /**
    Removes all key object pairs from user defaults
    */
    func clearUserDefaults() {
        for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key.description)
        }
    }
    
    //Token - Save / Get
    func saveToken(token: String) {
        userDefaults.setValue(token, forKey: udToken)
    }
    
    func getToken() -> String {
        return userDefaults.valueForKey(udToken)==nil ? "" : userDefaults.valueForKey(udToken) as String
    }
    
    //User - Save / Get
    func saveUserData(user: User) {
        saveUserID(user.userId)
        saveToken(user.userToken)
        saveEmailID(user.email)
        saveUserName(user.nickname)
        
        //Jan 9, 2015 6:52:14 PM
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        
        saveLastActive(dateFormatter.stringFromDate(user.lastActive))
        saveCreated(dateFormatter.stringFromDate(user.creationDate))
    }
    
    func updateLastActiveRecord() {
        let now = NSDate()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        saveLastActive(dateFormatter.stringFromDate(now))
    }
    
    func getUserData() -> User {
        let lastAcive: NSDate = dateFormatter.dateFromString(getLastActive())!
        let created: NSDate = dateFormatter.dateFromString(getCreated())!
        return User(id: getUserID(), token: getToken(), email: getEmailID(), name: getUserName(), creation: created, lastActive: lastAcive)
    }
    
    //Email - Save / Get
    private func saveEmailID(emailID: String) {
        userDefaults.setValue(emailID, forKey: udEmailID)
    }
    
    func getEmailID() -> String {
        return userDefaults.valueForKey(udEmailID)==nil ? "" : userDefaults.valueForKey(udEmailID) as String
    }
    
    //UserID - Save / Get
    private func saveUserID(userID: String) {
        userDefaults.setValue(userID, forKey: udUserID)
    }
    
    func getUserID() -> String {
        return userDefaults.valueForKey(udUserID)==nil ? "" : userDefaults.valueForKey(udUserID) as String
    }
    
    //UserName - Save / Get
    private func saveUserName(userName: String) {
        userDefaults.setValue(userName, forKey: udUserName)
    }
    
    func getUserName() -> String {
        return userDefaults.valueForKey(udUserName)==nil ? "" : userDefaults.valueForKey(udUserName) as String
    }
    
    //LastActive - Save / Get
    private func saveLastActive(lastActive: String) {
        userDefaults.setValue(lastActive, forKey: udLastActive)
    }
    
    func getLastActive() -> String {
        return userDefaults.valueForKey(udLastActive) == nil ? "" : userDefaults.valueForKey(udLastActive) as String
    }
    
    //Created - Save / Get
    private func saveCreated(created: String) {
        userDefaults.setValue(created, forKey: udCreated)
    }
    
    func getCreated() -> String {
        return userDefaults.valueForKey(udCreated)==nil ? "" : userDefaults.valueForKey(udCreated) as String
    }
    
    //NightTime - Save / Get
    func saveNight(night: String) {
        userDefaults.setValue(night, forKey: udNight)
    }
    
    func getNight() -> String {
        return userDefaults.valueForKey(udNight)==nil ? "" : userDefaults.valueForKey(udNight) as String
    }
}
