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
    
    func addDaysToDate(days: Int) -> NSDate {
        
        var components = NSDateComponents()
        components.setValue(days, forComponent: NSCalendarUnit.CalendarUnitDay);
        var newDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: self, options: NSCalendarOptions(0))
        return newDate!
    }
    
    func hasPassed() -> Bool {
        if self.timeIntervalSinceNow < 0.0 {
            return true
        }
        
        return false
    }
    
    /**
    Compares the current date to a date in the past to get how long ago it
    was in the given unit
    
    :param: date A NSDate that happened in the past
    
    :returns: components
    */
    func differenceToNow(unit: NSCalendarUnit) -> NSDateComponents {
        
        var now = NSDate()
        var calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let date1 = calendar.startOfDayForDate(self)
        let date2 = calendar.startOfDayForDate(now)
        
        let components = calendar.components(unit, fromDate: date1, toDate: date2, options: nil)
        
        return components
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
    
    func toFullDateString() -> String {
        var dateformat: NSDateFormatter = NSDateFormatter()
        dateformat.dateStyle = NSDateFormatterStyle.MediumStyle
        dateformat.timeStyle = NSDateFormatterStyle.MediumStyle
        return dateformat.stringFromDate(self)
    }
    
    func toShortDateString() -> String {
        var dateformat: NSDateFormatter = NSDateFormatter()
        dateformat.dateFormat = "MMMM dd"
        return dateformat.stringFromDate(self)
    }
    
    func toShortTimeString() -> String {
        var dateformat: NSDateFormatter = NSDateFormatter()
        dateformat.dateFormat = "h a"
        return dateformat.stringFromDate(self)
    }
    
    func toRFC822String() -> String {
        var dateformat: NSDateFormatter = NSDateFormatter()
        dateformat.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
        return dateformat.stringFromDate(self)
    }
}