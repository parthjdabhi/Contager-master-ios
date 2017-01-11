//
//  InputPlansViewController.swift
//  Calendar
//
//  Created by Leqi Long on 8/5/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData
import Firebase

protocol InputPlansViewControllerDelegate {
    func addActivities(newActivity: Activity)
}

class InputPlansViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
//MARK: -Outlets
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var plansTextField: UITextField!
    
//MARK: -Properties
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    var userSetTime: NSDate?
    var currentDate: NSDate?
    var selectedDate: NSDate?
    var delegate: InputPlansViewControllerDelegate?
    var imageStrings = [
        "briefcase.png",
        "travel.png",
        "vacation.png",
        "food.png",
        "hot-chocolate-xxl.png"
    ]
    
    var selectedCategoryIndex: Int? = 0
    
    var ref = FIRDatabase.database().reference()
    
    var userID = FIRAuth.auth()?.currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        plansTextField.delegate = self
        datePickerView.addTarget(self, action: #selector(InputPlansViewController.datePickerChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        print("currentDate is \(currentDate)!!!")
    }
    
    func datePickerChanged(sender: AnyObject?)
    {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        let strDate = formatter.stringFromDate(datePickerView.date)
        print("strDate is \(strDate)")
        userSetTime = datePickerView.date
        
    }
    
    func updateTable(activity: Activity) {
        delegate?.addActivities(activity)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject)
    {
        // Save Clender item
        if plansTextField.text != "" {
            
            
            var dic = ["uid" : userID ] as [String:AnyObject]
            dic["detail"] = plansTextField.text ?? "detail"
            dic["time"] = "\(userSetTime?.timeIntervalSince1970 ?? datePickerView.date.timeIntervalSince1970)"
            dic["selectedDate"] = "\(selectedDate?.timeIntervalSince1970 ?? datePickerView.date.timeIntervalSince1970)"
            dic["createdAt"] = "\(NSDate().timeIntervalSince1970)"
            print("activity --> \(dic)!!!")
            
            if let selectedCategoryIndex = selectedCategoryIndex {
                dic["category"] = imageStrings[selectedCategoryIndex]
            }
            
            ref.child("users").child(userID).child("Activity").childByAutoId().setValue(dic)
            
            
            let activity = Activity()
            activity.detail = plansTextField.text
            activity.time = userSetTime ?? datePickerView.date
            activity.date = currentDate
            activity.selectedDate = selectedDate
            print("activity.selectedDate in InputPlansViewControlleris \(activity.selectedDate)!!!")
            if let selectedCategoryIndex = selectedCategoryIndex{
                activity.category = imageStrings[selectedCategoryIndex]
            }
            
            
            let alert = UIAlertController(title: "Notification", message: "Your calender activity Has Been Saved", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                //self.dismissViewControllerAnimated(true, completion: nil)
                //self.navigationController?.popViewControllerAnimated(true)  //Changed to Push
                self.updateTable(activity)
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            displayError("Oops. You didn't enter any texts")
            //CommonUtils.sharedUtils.showAlert(self, title: "Error", message: "Please input the description.")
        }
    }
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let componentView = UIView(frame: CGRectMake(0, 0, pickerView.bounds.width - 30, 60))
        let componentImageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        
        var rowString = String()
        switch row{
        case 0:
            rowString = "Work"
            componentImageView.image = UIImage(named: imageStrings[0])
        case 1:
            rowString = "Travel"
            componentImageView.image = UIImage(named: imageStrings[1])
        case 2:
            rowString = "Vacation"
            componentImageView.image = UIImage(named: imageStrings[2])
        case 3:
            rowString = "Food"
            componentImageView.image = UIImage(named: imageStrings[3])
        case 4:
            rowString = "Relax"
            componentImageView.image = UIImage(named: imageStrings[4])
        default:
            break
        }
        
        let label = UILabel(frame: CGRectMake(60, 0, pickerView.bounds.width - 90, 60 ))
        label.text = rowString
        
        componentView.addSubview(label)
        componentView.addSubview(componentImageView)
        
        return componentView
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryIndex = row
        print("selectedCategoryIndex is now \(selectedCategoryIndex)!!!")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
