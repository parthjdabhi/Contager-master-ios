//
//  SocialMediaViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/29/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import SDWebImage
import FBSDKCoreKit

class SocialMediaViewController: UIViewController {

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
    @IBOutlet var linkedInCircle: UIImageView!
    
    
    var ref:FIRDatabaseReference!
    
    var facebookData: Dictionary<String, AnyObject>?
    var twitterData: Dictionary<String, AnyObject>?
    var instagramData: Dictionary<String, AnyObject>?
    var linkedinData: Dictionary<String, AnyObject>?
    
    var facebookId: String = ""
    var twitterId: String = ""
    var linkedinId: String = ""
    var instagramId: String = ""
    
    override func viewDidLoad() {
        greenLine1.transform = CGAffineTransformMakeRotation(40)
        greenLine2.transform = CGAffineTransformMakeRotation(25)
        greenLine3.transform = CGAffineTransformMakeRotation(-25)
        greenLine4.transform = CGAffineTransformMakeRotation(-40)
        
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
        }
        
        image1.layer.borderWidth = 2
        image1.layer.borderColor = UIColor.whiteColor().CGColor
        
    }
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
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
                self.twitterId = twitterDictionary.objectForKey("userLastName") as? String ?? ""
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
                self.linkedInCircle.hidden = true
                self.linkedin.hidden = true
                self.greenLine4.hidden = true
                print("no linkedin data")
            }
        })
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.currentAccessToken() != nil)
        {
            //buttonEnable(true)
            
            //print permissions, such as public_profile
            print(FBSDKAccessToken.currentAccessToken().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                //self.label.text = result.valueForKey("name") as? String
                
                let FBid = result.valueForKey("id") as? String

                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
                //self.imageView.image = UIImage(data: NSData(contentsOfURL: url!)!)
            })
        } else {
            //buttonEnable(false)
        }
    }
    
    @IBAction func twitterButton(sender: AnyObject) {
        //let twitterId = "iamparthdabhi" //userLastName
        let twitterAppURL = "twitter://user?screen_name=" + twitterId
        let twitterWebSiteURL = "https://twitter.com/" + twitterId
        UIApplication.tryURL([
            twitterAppURL, // App
            twitterWebSiteURL// Website if app fails
            ])
        
//        UIApplication.tryURL([
//            "twitter://appforequity", // App
//            "https://twitter.com/appforequity" // Website if app fails
//            ])
    }
    @IBAction func facebookButton(sender: AnyObject) {
        UIApplication.tryURL([
            //"fb://profile/\(self.facebookId)", // App -- it seems to be not working now
            "http://www.facebook.com/app_scoped_user_id/\(self.facebookId)" // Website if app fails
            ])
//        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
//        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
//            //self.label.text = result.valueForKey("name") as? String
//            
//            let FBid = result?.valueForKey("id") as? String
//            let fbIDString = FBid ?? self.facebookId
//        UIApplication.tryURL([
//            "fb://profile/\(fbIDString)", // App
//            "http://www.facebook.com/\(fbIDString)" // Website if app fails
//            ])
//        })
    }
    @IBAction func instagramButton(sender: AnyObject) {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
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
        //instagram://user?username=
        UIApplication.tryURL([
            "instagram://barelabor/", // App
            "https://www.instagram.com/barelabor/" // Website if app fails
            ])*/
    }
    
    @IBAction func linkedInButton(sender: AnyObject) {
        UIApplication.tryURL([
            //"linkedin://in/dustin-allen-137b25ba", // App
            //"https://www.linkedin.com/in/dustin-allen-137b25ba" // Website if app fails
            linkedinId
            ])
    }
    
}
