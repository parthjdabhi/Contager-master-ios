//
//  AddContactViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/23/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Contacts

class AddContactViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var contact: CNContact {
        get {
            let store = CNContactStore()
            
            let contactToAdd = CNMutableContact()
            contactToAdd.givenName = self.firstName.text ?? ""
            contactToAdd.familyName = self.lastName.text ?? ""
            
            let mobileNumber = CNPhoneNumber(stringValue: (self.mobileNumber.text ?? ""))
            let mobileValue = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: mobileNumber)
            contactToAdd.phoneNumbers = [mobileValue]
            
            let email = CNLabeledValue(label: CNLabelHome, value: (self.homeEmail.text ?? ""))
            contactToAdd.emailAddresses = [email]
            
            if let image = self.contactImage.image {
                contactToAdd.imageData = UIImagePNGRepresentation(image)
            }
            
            let saveRequest = CNSaveRequest()
            saveRequest.addContact(contactToAdd, toContainerWithIdentifier: nil)
            
            do {
                try store.executeSaveRequest(saveRequest)
            } catch {
                print(error)
            }
            
            return contactToAdd
        }
    }
    
    @IBOutlet var addImage: UIButton!

    @IBOutlet var contactImage: UIImageView!
    
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var mobileNumber: UITextField!
    @IBOutlet var homeEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressDone(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("addNewContact", object: nil, userInfo: ["contactToAdd": self.contact])
        self.navigationController?.navigationController?.popViewControllerAnimated(true)
        
    }
    
    @IBAction func didAddImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.contactImage.image = image
        UIView.animateWithDuration(0.3) { () -> Void in
            self.contactImage.alpha = 1.0
            self.addImage.alpha = 0.0
        }
    }

}
