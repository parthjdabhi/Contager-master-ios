//
//  InputPlansViewController.swift
//  Calendar
//
//  Created by Leqi Long on 8/5/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

protocol InputPlansViewControllerDelegate{
    func fetchActivities(selectedDate: NSDate?)
}

class InputPlansViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
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
    var currentDate: DateShort?
    var selectedDate: NSDate?
    var delegate: InputPlansViewControllerDelegate?
    var imageStrings = [
        "briefcase.png",
        "travel.png",
        "vacation.png",
        "food.png",
        "hot-chocolate-xxl.png"
    ]
    
    var selectedCategoryIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        plansTextField.delegate = self
        datePickerView.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        print("currentDate is \(currentDate)!!!")
    }
    
    func datePickerChanged(sender: AnyObject?){
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        
        let strDate = formatter.stringFromDate(datePickerView.date)
        print("strDate is \(strDate)")
        userSetTime = datePickerView.date
        
    }
    
    func updateTable(selectedDate: NSDate?){
        delegate?.fetchActivities(selectedDate)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        if plansTextField.text != ""{
            let activity = Activity(detail: plansTextField.text!, context: self.context)
            activity.time = userSetTime ?? datePickerView.date
            activity.date = currentDate
            activity.selectedDate = selectedDate
            print("activity.selectedDate in InputPlansViewControlleris \(activity.selectedDate)!!!")
            if let selectedCategoryIndex = selectedCategoryIndex{
                activity.category = imageStrings[selectedCategoryIndex]
            }
            do{
               try context.save()
            }catch{}
            
            updateTable(selectedDate)
            
            dismissViewControllerAnimated(true, completion: nil)
        }else{
            displayError("Oops. You didn't enter any texts")
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
        var componentView = UIView(frame: CGRectMake(0, 0, pickerView.bounds.width - 30, 60))
        var componentImageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
        
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
