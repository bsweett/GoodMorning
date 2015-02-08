//
//  DateExtensions.swift
//  GoodMorning
//
//  Created by Ben Sweett on 2015-01-28.
//  Copyright (c) 2015 Ben Sweett. All rights reserved.
//

import Foundation

extension NSDate {
    
    func addMonthsToDate(months: Int) -> NSDate {
        
        var components = NSDateComponents()
        components.setValue(months, forComponent: NSCalendarUnit.CalendarUnitMonth);
        var newDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(0))
        return newDate!
    }
    
    func addMinutesToDate(minutes: Int) -> NSDate {
        
        var components = NSDateComponents()
        components.setValue(minutes, forComponent: NSCalendarUnit.CalendarUnitMinute);
        var newDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(0))
        return newDate!
    }
    
    /*
        Returns a Time String in the HH:mm:ss from for a date
    
        :return: String
    */
    func toTimeString() -> String {
        var timeformat: NSDateFormatter = NSDateFormatter()
        timeformat.dateFormat = "HH:mm:ss"
        return timeformat.stringFromDate(self)
    }
}