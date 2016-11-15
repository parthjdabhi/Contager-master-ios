//
//  FriendSocialMediaViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 7/12/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import SDWebImage

class FriendSocialMediaViewController: UIViewController {
    
    @IBOutlet var linkedin: UIButton!
    @IBOutlet var instagram: UIButton!
    @IBOutlet var facebook: UIButton!
    @IBOutlet var twitter: UIButton!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var greenLine1: UIImageView!
    @IBOutlet var greenLine2: UIImageView!
    @IBOutlet var greenLine3: UIImageView!
    @IBOutlet var greenLine4: UIImageView!
    @IBOutlet var twitterCircle: UIImageView!
    @IBOutlet var facebookCircle: UIImageView!
    @IBOutlet var instagramCircle: UIImageView!
    @IBOutlet var linkedInCIrcle: UIImageView!
    
    var ref:FIRDatabaseReference!
    var facebookId: String!
    var twitterId: String!
    var linkedinId: String!
    var instagramId: String!
    
    @IBAction func homeButton(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewDidLoad() {
        
        greenLine1.transform = CGAffineTransformMakeRotation(40)
        greenLine2.transform = CGAffineTransformMakeRotation(25)
        greenLine3.transform = CGAffineTransformMakeRotation(-25)
        greenLine4.transform = CGAffineTransformMakeRotation(-40)
        
        if let friend = AppState.sharedInstance.friend {
            
            self.image1.image = friend.getImage()
        }
        
        ref = FIRDatabase.database().reference()
        let userID = AppState.sharedInstance.friend?.getUid()
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        
        if let friend = AppState.sharedInstance.friend {
            let imageExist = friend.imageExist()
            if imageExist {
                let image = friend.getImage()
                self.image1.image = image
            } else {
                if !friend.getUserPhotoURL().isEmpty {
                    self.image1.sd_setImageWithURL(NSURL(string: friend.getUserPhotoURL()), placeholderImage: UIImage(named: "no-pic.png"))
                }
            }
        }
        
        
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            CommonUtils.sharedUtils.hideProgress()
            if snapshot.hasChild("facebookData") {
                let facebookDictionary = snapshot.value!["facebookData"] as! NSDictionary!
                self.facebookId = facebookDictionary.objectForKey("userId") as! String!
                //print("User id", self.facebookId)
                print("facebookDictionary: ", facebookDictionary)
            } else {
                self.facebookCircle.hidden = true
                self.facebook.hidden = true
                self.greenLine2.hidden = true
            }
            
            // Twitter
            if snapshot.hasChild("twitterData") {
                let twitterDictionary = snapshot.value!["twitterData"] as! NSDictionary!
                self.twitterId = twitterDictionary.objectForKey("userLastName") as! String!
                print("there is twitter data")
                print("twitter Data: ", twitterDictionary)
            } else {
                self.twitterCircle.hidden = true
                self.twitter.hidden = true
                self.greenLine1.hidden = true
                print("no twitter data")
            }
            
            // Instagram
            if let username = snapshot.value!["instagram"] as! String! {
                if username == "" {
                    self.instagramCircle.hidden = true
                    self.instagram.hidden = true
                    self.greenLine3.hidden = true
                    print("no instagram data")
                } else {
                    print(username)
                }
            }
            
            /*
            if snapshot.hasChild("instagramData") {
                let instagramDictionary = snapshot.value!["instagramData"] as! NSDictionary!
                self.instagramId = instagramDictionary.objectForKey("userId") as! String!
                print("there is instagram data")
                print("instagram Data: ", instagramDictionary)
            } else {
                self.instagramCircle.hidden = true
                self.instagram.hidden = true
                self.greenLine3.hidden = true
                print("no instagram data")
            }*/
            
            // Linkedin
            if snapshot.hasChild("linkedinData") {
                let linkedinDictionary = snapshot.value!["linkedinData"] as! NSDictionary!
                self.linkedinId = linkedinDictionary.objectForKey("url") as! String! //userId
                print("there is linkedin data")
                print("linkedin Data: ", linkedinDictionary)
            } else {
                self.linkedInCIrcle.hidden = true
                self.linkedin.hidden = true
                self.greenLine4.hidden = true
                print("no linkedin data")
            }
        })
        
        image1.layer.borderWidth = 2
        image1.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func twitterButton(sender: AnyObject) {
        let twitterAppURL = "twitter://user?screen_name=" + twitterId
        let twitterWebSiteURL = "https://twitter.com/" + twitterId
        UIApplication.tryURL([
            twitterAppURL, // App
             twitterWebSiteURL// Website if app fails
            ])
    }
    
    @IBAction func facebookButton(sender: AnyObject) {
        //let facebookAppURL = "fb://profile/" + facebookId
        //https:// www.facebook.com/app_scoped_user_id/670839443061245
        let facebookWebSiteURL = "http://www.facebook.com/app_scoped_user_id/" + facebookId
        UIApplication.tryURL([
            //facebookAppURL, // App url -- it might seems to be not working now
            facebookWebSiteURL // Website if app fails
            ])
    }
    
    @IBAction func instagramButton(sender: AnyObject) {
        ref = FIRDatabase.database().reference()
        let userID = AppState.sharedInstance.friend?.getUid()
        
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            CommonUtils.sharedUtils.hideProgress()
            if let username = snapshot.value!["instagram"] as! String! {
                let instagramHooks = "instagram://user?username=\(username)"
                let instagramUrl = NSURL(string: instagramHooks)
                if UIApplication.sharedApplication().canOpenURL(instagramUrl!)
                {
                    UIApplication.sharedApplication().openURL(instagramUrl!)
                    
                } else {
                    //redirect to safari because the user doesn't have Instagram
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://instagram.com/\(username)")!)
                }
            }
        })
        
        /*
        let instagramAppURL = "instagram://" + instagramId
        let instagramWebSiteURL = "https://www.instagram.com/" + instagramId
        UIApplication.tryURL([
            instagramAppURL, // App
            instagramWebSiteURL // Website if app fails
            ])*/
    }
    
    @IBAction func linkedInButton(sender: AnyObject) {
        let linkedinAppURL = "linkedin://in/" + linkedinId
        let linkedinWebSiteURL = "https://www.linkedin.com/in/" + linkedinId
        UIApplication.tryURL([
            linkedinAppURL, // App
            linkedinWebSiteURL // Website if app fails
            ])
    }
    
}
