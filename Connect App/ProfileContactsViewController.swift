//
//  ProfileContactsViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/29/16.
//  Copyright © 2016 Harloch. All rights reserved.
//



import UIKit
import MessageUI
import Foundation
import Firebase
import SDWebImage

class ProfileContactsViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var email: UIButton!
    @IBOutlet var phone: UIButton!
    @IBOutlet var text: UIButton!
    @IBOutlet var image: UIImageView!
    @IBOutlet var greenLine1: UIImageView!
    @IBOutlet var greenLine2: UIImageView!
    @IBOutlet var greenLine3: UIImageView!
    @IBOutlet var greenLine4: UIImageView!
    @IBOutlet var textCircle: UIImageView!
    @IBOutlet var phoneCircle: UIImageView!
    
    
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        greenLine1.transform = CGAffineTransformMakeRotation(40)
        greenLine2.transform = CGAffineTransformMakeRotation(25)
        greenLine3.transform = CGAffineTransformMakeRotation(-25)
        greenLine4.transform = CGAffineTransformMakeRotation(-40)
        
        if let currentUser = AppState.sharedInstance.currentUser {
            if let imageStr = currentUser.value!["image"] as? String {
                self.image.image = CommonUtils.sharedUtils.decodeImage(imageStr)
            } else {
                if let facebookData = currentUser.value!["facebookData"] as? [String : String] {
                    if let image_url = facebookData["profilePhotoURL"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.image.sd_setImageWithURL(url)
                    }
                } else if let twitterData = currentUser.value!["twitterData"] as? [String : String] {
                    if let image_url = twitterData["profile_image_url"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.image.sd_setImageWithURL(url)
                    }
                }
            }
        }
        
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.whiteColor().CGColor
    }
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let userPhoneNumber = snapshot.value!["userPhone"]{
                if userPhoneNumber == nil {
                    self.phoneCircle.hidden = true
                    self.textCircle.hidden = true
                    self.phone.hidden = true
                    self.text.hidden = true
                    self.greenLine2.hidden = true
                    self.greenLine3.hidden = true
                } else {
                    self.phoneCircle.hidden = false
                    self.textCircle.hidden = false
                    self.phone.hidden = false
                    self.text.hidden = false
                    self.greenLine2.hidden = false
                    self.greenLine3.hidden = false
                }
                if let user = FIRAuth.auth()?.currentUser {
                    let email = user.email
                    print(email)
                    if email == nil {
                        self.greenLine1.hidden = true
                        self.email.hidden = true
                    }
                } else {
                    ("Email is avaiable")
                }
                
            }})
        { (error) in
            print(error.localizedDescription)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func emailButton(sender: AnyObject) {
        if let user = FIRAuth.auth()?.currentUser {
            let email = user.email as String!
            let alert = UIAlertController(title: "Email Address", message: "\(email)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Email", style: UIAlertActionStyle.Default, handler: { action in
                let mailComposeViewController = self.configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }}
    @IBAction func phoneButton(sender: AnyObject) {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let userPhoneNumber = snapshot.value!["userPhone"]{
                let userPhoneString = userPhoneNumber as! String!
                if userPhoneString == nil {
                    print("No Phone Number")
                } else {
                    let alert = UIAlertController(title: "Phone Number", message: "\(userPhoneString)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.Default, handler: { action in
                        let phone = "2148089614";
                        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phone)")!)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            }
        )}
    
    
    
    @IBAction func textButton(sender: AnyObject) {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let userPhoneNumber = snapshot.value!["userPhone"]{
                let userPhoneString = userPhoneNumber as! String!
                if userPhoneString == nil {
                    print("No Phone Number")
                } else {
                    let alert = UIAlertController(title: "Phone Number", message: "\(userPhoneString)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Text", style: UIAlertActionStyle.Default, handler: { action in
                        let messageVC = MFMessageComposeViewController()
                        messageVC.body = "Hi";
                        messageVC.recipients = ["\(userPhoneString)"]
                        messageVC.messageComposeDelegate = self;
                        self.presentViewController(messageVC, animated: false, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }}})}

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("Snagged!")
        mailComposerVC.setMessageBody("You've been snagged!", isHTML: false)
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail. Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message cancelled")
        case MessageComposeResultFailed.rawValue :
            print("message failed")
        case MessageComposeResultSent.rawValue :
            print("message sent")
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func calendarButton(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CalendarViewController") as! CalendarViewController!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}