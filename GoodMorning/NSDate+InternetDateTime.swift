//
//  NSDate+InternetDateTime.swift
//
//  Objective-C Version created by Michael Waterfall on 07/10/2010.
//  Copyright 2010 Michael Waterfall. All rights reserved.
//
//  Swift Version created by Alexander Sparkowsky on 19/07/14.
//  Copyright (c) 2014 Alexander Sparkowsky. All rights reserved.
//

import Foundation

enum DateFormatHint {
    case RFC3339, RFC822
}

extension NSDate {
    // Good info on internet dates here: http://developer.apple.com/iphone/library/qa/qa2010/qa1480.html
    
    func dateFromInternetDateTimeString(dateString: String, formatHint: DateFormatHint) -> NSDate? {
        var date: NSDate?
        
        if formatHint != .RFC3339 {
            // Try RFC822 first
            date = NSDate.dateFromRFC822String(dateString)
            if (date == nil) {
                date = NSDate.dateFromRFC3339String(dateString)
            }
        } else {
            // Try RFC3339 first
            date = NSDate.dateFromRFC3339String(dateString)
            if (date == nil) {
                date = NSDate.dateFromRFC822String(dateString)
            }
        }
        
        return date
    }
    
    // See http://www.faqs.org/rfcs/rfc822.html
    class func dateFromRFC822String(dateString: String) -> NSDate? {
        
        // Create date formatter
//        NSDateFormatter *dateFormatter = nil;
//        if (!dateFormatter) {
            let en_US_POSIX = NSLocale(localeIdentifier: "en_US_POSIX")
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = en_US_POSIX
            dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
//        }
        
        // Process
        var date: NSDate?

        let RFC822String = String(dateString).uppercaseString

        if RFC822String.rangeOfString(",") != nil {
            if (date == nil) { // Sun, 19 May 2002 15:21:36 GMT
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
                date = dateFormatter.dateFromString(RFC822String)
            }
            if (date == nil) { // Sun, 19 May 2002 15:21 GMT
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm zzz"
                date = dateFormatter.dateFromString(RFC822String)
            }
            if (date == nil) { // Sun, 19 May 2002 15:21:36
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss"
                date = dateFormatter.dateFromString(RFC822String)
            }
            if (date == nil) { // Sun, 19 May 2002 15:21
                dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm"
                date = dateFormatter.dateFromString(RFC822String)
            }
        } else {
            if (date == nil) { // 19 May 2002 15:21:36 GMT
                dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss zzz"
                date = dateFormatter.dateFromString(RFC822String)
            }
            if (date == nil) { // 19 May 2002 15:21 GMT
                dateFormatter.dateFormat = "d MMM yyyy HH:mm zzz"
                date = dateFormatter.dateFromString(RFC822String)
            }
            if (date == nil) { // 19 May 2002 15:21:36
                dateFormatter.dateFormat = "d MMM yyyy HH:mm:ss"
                date = dateFormatter.dateFromString(RFC822String)
            }
            if (date == nil) { // 19 May 2002 15:21
                dateFormatter.dateFormat = "d MMM yyyy HH:mm"
                date = dateFormatter.dateFromString(RFC822String)
            }
        }
        if (date == nil) {
            NSLog("Could not parse RFC822 date: \"\(dateString)\" Possibly invalid format.")
        }

        return date;
    }

    class func dateFromRFC3339String(dateString: String) -> NSDate? {
        
        // Create date formatter
        //        NSDateFormatter *dateFormatter = nil;
        //        if (!dateFormatter) {
        let en_US_POSIX = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = en_US_POSIX
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        //        }
        
        // Process
        var date: NSDate?

        var RFC3339String = String(dateString).uppercaseString
        RFC3339String = RFC3339String.stringByReplacingOccurrencesOfString("Z", withString: "-0000")

        // Remove colon in timezone as iOS 4+ NSDateFormatter breaks. See https://devforums.apple.com/thread/45837
        if countElements(RFC3339String) > 20 {
            let nsRange = NSMakeRange(20, countElements(RFC3339String) - 20)
            // Bridge String to NSString
            let RFC3339StringAsNSString: NSString = RFC3339String
            RFC3339String = RFC3339StringAsNSString.stringByReplacingOccurrencesOfString(":", withString: "", options: nil, range: nsRange)
        
        }

        if (date == nil) { // 1996-12-19T16:39:57-0800
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
            date = dateFormatter.dateFromString(RFC3339String)
        }
        if (date == nil) { // 1937-01-01T12:00:27.87+0020
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"
            date = dateFormatter.dateFromString(RFC3339String)
        }
        if (date == nil) { // 1937-01-01T12:00:27
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
            date = dateFormatter.dateFromString(RFC3339String)
        }

        if (date == nil) {
            NSLog("Could not parse RFC3339 date: \"\(dateString)\" Possibly invalid format.")
        }

        return date;
    }
}