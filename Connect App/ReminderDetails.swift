//
//  ReminderDetails.swift
//  Connect App
//
//  Created by Dustin Allen on 6/23/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import EventKit

class ReminderDetails: UIViewController {

    
    // Properties
    var datePicker: UIDatePicker!
    var reminder: EKReminder!
    var eventStore: EKEventStore!
    
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet weak var reminderTextView: UITextView!
    
    
    @IBAction func saveReminder(sender: AnyObject) {
        self.reminder.title = reminderTextView.text
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let dueDateComponents = appDelegate.dateComponentFromNSDate(self.datePicker.date)
        reminder.dueDateComponents = dueDateComponents
        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
        do {
            try self.eventStore.saveReminder(reminder, commit: true)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }catch{
            print("Error creating and saving new reminder : \(error)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reminderTextView.text = self.reminder.title
        datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(ReminderDetails.addDate), forControlEvents: UIControlEvents.ValueChanged)
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        dateTextField.inputView = datePicker
        reminderTextView.becomeFirstResponder()
        
    }
    
    func addDate(){
        self.dateTextField.text = self.datePicker.date.description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
