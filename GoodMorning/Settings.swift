//
//  File.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2014-12-17.
//  Copyright (c) 2014 Ben Sweett. All rights reserved.
//

import Foundation

class Settings: NSObject {
 
    var speechEnabled: Bool
    var offlineMode: Bool
    var manualLocation: String
    
    override init() {
        speechEnabled = false
        offlineMode = false
        manualLocation = ""
    }
    
    //TODO: Using core data and storing settings
    func saveSettings() {
        
    }
    
    
}


