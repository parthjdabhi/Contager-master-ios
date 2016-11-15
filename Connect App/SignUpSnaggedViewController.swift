//
//  SignUpSnaggedViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/27/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import TwitterKit
import Fabric
import Firebase

class SignUpSnaggedViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var phoneField: UITextField!
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        
        let paddingView = UIView(frame:CGRectMake(0, 0, 20, 20))
        firstNameField.leftView = paddingView;
        firstNameField.leftViewMode = UITextFieldViewMode.Always
        firstNameField.text = "First Name"
        firstNameField.textColor = UIColor.whiteColor()
        lastNameField.text = "Last Name"
        lastNameField.textColor = UIColor.whiteColor()
        let paddingForFirst = UIView(frame: CGRectMake(0, 0, 20, self.lastNameField.frame.size.height))
        lastNameField.leftView = paddingForFirst
        lastNameField.leftViewMode = UITextFieldViewMode .Always
        lastNameField.font = UIFont(name: lastNameField.font!.fontName, size: 15)
        emailField.text = "Email"
        emailField.textColor = UIColor.whiteColor()
        let paddingForSecond = UIView(frame: CGRectMake(0, 0, 20, self.emailField.frame.size.height))
        emailField.leftView = paddingForSecond
        emailField.leftViewMode = UITextFieldViewMode .Always
        emailField.font = UIFont(name: emailField.font!.fontName, size: 15)
        passwordField.text = "Password"
        passwordField.textColor = UIColor.whiteColor()
        let paddingForThird = UIView(frame: CGRectMake(0, 0, 20, self.passwordField.frame.size.height))
        passwordField.leftView = paddingForThird
        passwordField.leftViewMode = UITextFieldViewMode .Always
        passwordField.font = UIFont(name: passwordField.font!.fontName, size: 15)
        phoneField.text = "Telephone Number"
        phoneField.textColor = UIColor.whiteColor()
        let paddingForFourth = UIView(frame: CGRectMake(0, 0, 20, self.phoneField.frame.size.height))
        phoneField.leftView = paddingForFourth
        phoneField.leftViewMode = UITextFieldViewMode .Always
        phoneField.font = UIFont(name: phoneField.font!.fontName, size: 15)
    }
    
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
        self.phoneField.delegate = self
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func createProfile(sender: AnyObject) {
        let email = self.emailField.text!
        let password = self.passwordField.text!
        // make sure the user entered both email & password
        if email != "" && password != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": self.firstNameField.text!, "userLastName": self.lastNameField.text!, "email": email, "userPhoneNumber": self.phoneField.text!])
                    CommonUtils.sharedUtils.hideProgress()
                    let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController!
                    self.navigationController?.pushViewController(photoViewController, animated: true)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Enter email & password!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
        }
        
        /*
        func setDisplayName(user: FIRUser) {
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
            changeRequest.commitChangesWithCompletion(){ (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.signedIn(FIRAuth.auth()?.currentUser)
            }
        }
        
        func signedIn(user: FIRUser?) {
            MeasurementHelper.sendLoginEvent()
            
            AppState.sharedInstance.displayName = user?.displayName ?? user?.email
            AppState.sharedInstance.photoUrl = user?.photoURL
            AppState.sharedInstance.signedIn = true
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
            performSegueWithIdentifier(Constants.Segues.AddSocial, sender: nil)
        }
    }*/
    }
    
    @IBAction func firstNameAction(sender: AnyObject) {
        SignUpSocialViewController.firstName = firstNameField.text!
    }
    
    @IBAction func lastNameAction(sender: AnyObject) {
        SignUpSocialViewController.lastName = lastNameField.text!
    }
    
    @IBAction func emailAction(sender: AnyObject) {
        SignUpSocialViewController.email = emailField.text!
    }
    
    @IBAction func passwordAction(sender: AnyObject) {
        SignUpSocialViewController.password = passwordField.text!
    }
    
    @IBAction func phoneAction(sender: AnyObject) {
        SignUpSocialViewController.phone = phoneField.text!
    }
    
}