//
//  TheCalendarViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/24/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import EventKit

class TheCalendarViewController: UIViewController, CalendarViewDataSource, CalendarViewDelegate {
    
    
    @IBOutlet weak var calendarView: CalendarView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        // change the code to get a vertical calender.
        calendarView.direction = .Horizontal
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.loadEventsInCalendar()
        
        let dateComponents = NSDateComponents()
        dateComponents.day = -5
        
        let today = NSDate()
        
        if let date = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions()) {
            self.calendarView.selectDate(date)
            //self.calendarView.deselectDate(date)
        }
        
        
    }
    
    // MARK : KDCalendarDataSource
    
    func startDate() -> NSDate? {
        
        let dateComponents = NSDateComponents()
        dateComponents.month = -3
        
        let today = NSDate()
        
        let threeMonthsAgo = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        
        
        return threeMonthsAgo
    }
    
    func endDate() -> NSDate? {
        
        let dateComponents = NSDateComponents()
        
        dateComponents.year = 2;
        let today = NSDate()
        
        let twoYearsFromNow = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        
        return twoYearsFromNow
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let width = self.view.frame.size.width - 16.0 * 2
        let height = width + 20.0
        self.calendarView.frame = CGRect(x: 16.0, y: 32.0, width: width, height: height)
        
        
    }
    
    
    
    // MARK : KDCalendarDelegate
    
    func calendar(calendar: CalendarView, didSelectDate date : NSDate, withEvents events: [EKEvent]) {
        
        if events.count > 0 {
            let event : EKEvent = events[0]
            print("We have an event starting at \(event.startDate) : \(event.title)")
        }
        print("Did Select: \(date) with Events: \(events.count)")
        
        
        
    }
    
    func calendar(calendar: CalendarView, didScrollToMonth date : NSDate) {
        
        self.datePicker.setDate(date, animated: true)
    }
    
    // MARK : Events
    
    func loadEventsInCalendar() {
        
        if let  startDate = self.startDate(),
            endDate = self.endDate() {
            
            let store = EKEventStore()
            
            let fetchEvents = { () -> Void in
                
                let predicate = store.predicateForEventsWithStartDate(startDate, endDate:endDate, calendars: nil)
                
                // if can return nil for no events between these dates
                if let eventsBetweenDates = store.eventsMatchingPredicate(predicate) as [EKEvent]? {
                    
                    self.calendarView.events = eventsBetweenDates
                    
                }
                
            }
            
            // let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
            
            if EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) != EKAuthorizationStatus.Authorized {
                
                store.requestAccessToEntityType(EKEntityType.Event, completion: {(granted, error ) -> Void in
                    if granted {
                        fetchEvents()
                    }
                })
                
            }
            else {
                fetchEvents()
            }
            
        }
        
    }
    
    
    // MARK : Events
    
    @IBAction func onValueChange(picker : UIDatePicker) {
        
        self.calendarView.setDisplayDate(picker.date, animated: true)
        
        
    }
    
}