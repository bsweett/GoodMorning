//
//  BoolExtensions.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-02-11.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

extension Bool {
    
    func toString() -> String {
        if self {
            return "true"
        } else {
            return "false"
        }
    }
    
}