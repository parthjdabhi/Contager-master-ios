//
//  PortalViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 7/6/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

class PortalViewController: UIViewController {
    
    @IBOutlet var noteOnlyLabel: UILabel!
    @IBOutlet var nameNoteLabel: UILabel!
    @IBOutlet var image1: UIImageView!
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(animated: Bool) {
        
        image1.layer.borderWidth = 2
        image1.layer.borderColor = UIColor.whiteColor().CGColor
        
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        if let currentUser = AppState.sharedInstance.currentUser {
            if let imageStr = currentUser.value!["image"] as? String {
                self.image1.image = CommonUtils.sharedUtils.decodeImage(imageStr)
            } else {
                if let facebookData = currentUser.value!["facebookData"] as? [String : String] {
                    if let image_url = facebookData["profilePhotoURL"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.image1.sd_setImageWithURL(url)
                    }
                } else if let twitterData = currentUser.value!["twitterData"] as? [String : String] {
                    if let image_url = twitterData["profile_image_url"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.image1.sd_setImageWithURL(url)
                    }
                }
            }
            if currentUser.value?["userFirstName"] != nil && currentUser.value?["userLastName"] != nil {
                let firstNameStr = currentUser.value?["userFirstName"] as! String
                let lastNameStr = currentUser.value?["userLastName"] as! String
                self.nameNoteLabel.text = "\(firstNameStr) \(lastNameStr)"
            }} else {
            print("error")
        }
        
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func selectContactsSocialView(sender: AnyObject) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ContactSocialViewController") as! ContactSocialViewController!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func backButton(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}