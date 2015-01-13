//
//  ApplicationDataManager.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-12.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

class ApplicationDataManager: NSObject {
    
    var user: User? = nil
    var settings: Settings? = nil

    class var sharedInstance : ApplicationDataManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ApplicationDataManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ApplicationDataManager()
        }
        return Static.instance!
    }
    
    override init() {
    
    }
    
    func updateUserState(user: User) {
        self.user = user
    }
    
    func getUserState(user: User) -> User {
        return self.user!
    }
    
    // NOTE: This should only be done if the user wishes to reset the application for w.e. reason
    func removeUserState() {
        self.user = nil
    }
    
    func updateSetttingsState(settings: Settings) {
        self.settings = settings
    }
    
    func getSettingsState(user: Settings) -> Settings {
        return self.settings!
    }
    
    // NOTE: This should only be done if the user wishes to reset the application for w.e. reason
    func removeSettingsState() {
        self.settings = nil
    }
    
}
