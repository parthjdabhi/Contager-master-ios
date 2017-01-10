//
//  Extensions.swift
//  Connect App
//
//  Created by Dustin Allen on 7/1/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit


extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.sharedApplication()
        for url in urls {
            if application.canOpenURL(NSURL(string: url)!) {
                application.openURL(NSURL(string: url)!)
                return
            }
        }
    }
}


extension Array where Element: Equatable {
    func arrayRemovingObject(object: Element) -> [Element] {
        return filter { $0 != object }
    }
}

extension Array where Element: Equatable {
    
    mutating func removeEqualItems(item: Element) {
        self = self.filter { (currentItem: Element) -> Bool in
            return currentItem != item
        }
    }
    
    mutating func removeFirstEqualItem(item: Element) {
        guard var currentItem = self.first else { return }
        var index = 0
        while currentItem != item {
            index += 1
            currentItem = self[index]
        }
        self.removeAtIndex(index)
    }
    
}


extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}

extension NSDate {
    struct Formatter {
        static let custom = NSDateFormatter(dateFormat: "dd/M/yyyy, H:mm:ss")
    }
    var customFormatted: String {
        return Formatter.custom.stringFromDate(self)
    }
}

extension String {
    var asDate: NSDate? {
        return NSDate.Formatter.custom.dateFromString(self)
    }
    func asDateFormatted(with dateFormat: String) -> NSDate? {
        return NSDateFormatter(dateFormat: dateFormat).dateFromString(self)
    }
}



extension Double {
    var asDateFromMiliseconds: NSDate {
        return NSDate.init(timeIntervalSince1970: self)
    }
}

extension NSDate {
    
    func getElapsedInterval() -> String {
        
        var interval = NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year
        
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "year ago" :
                "\(interval)" + " " + "years ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: NSDate(), options: []).month
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "month ago" :
                "\(interval)" + " " + "months ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Day, fromDate: self, toDate: NSDate(), options: []).day
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "day ago" :
                "\(interval)" + " " + "days ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Hour, fromDate: self, toDate: NSDate(), options: []).hour
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour ago" :
                "\(interval)" + " " + "hours ago"
        }
        
        interval = NSCalendar.currentCalendar().components(.Minute, fromDate: self, toDate: NSDate(), options: []).minute
        if interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute ago" :
                "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        //NSCalendar.currentCalendar().compareDate(now, toDate: olderDate,toUnitGranularity: .Day)
        //Return Result
        return isLess
    }
    
    func isExpiredDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if NSCalendar.currentCalendar().compareDate(self, toDate: dateToCompare, toUnitGranularity: .Day) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        //
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}

func compareDate(date1:NSDate, date2:NSDate) -> Bool {
    let order = NSCalendar.currentCalendar().compareDate(date1, toDate: date2,
                                                         toUnitGranularity: .Day)
    switch order {
    case .OrderedSame:
        return true
    default:
        return false
    }
}

func compareDateWithUnit(date1: NSDate, toDate date2: NSDate, toUnitGranularity unit: NSCalendarUnit) -> NSComparisonResult {
    let now = NSDate()
    // "Sep 23, 2015, 10:26 AM"
    
    let olderDate = NSDate(timeIntervalSinceNow: -10000)
    // "Sep 23, 2015, 7:40 AM"
    
    var order = NSCalendar.currentCalendar().compareDate(now, toDate: olderDate,toUnitGranularity: .Hour)
    switch order {
    case .OrderedDescending:
        print("DESCENDING")
    case .OrderedAscending:
        print("ASCENDING")
    case .OrderedSame:
        print("SAME")
    }
    // Compare to hour: DESCENDING
    
    order = NSCalendar.currentCalendar().compareDate(now, toDate: olderDate,toUnitGranularity: .Day)
    
    switch order {
    case .OrderedDescending:
        print("DESCENDING")
    case .OrderedAscending:
        print("ASCENDING")
    case .OrderedSame:
        print("SAME")
    }
    // Compare to day: SAME
    
    return order
}
