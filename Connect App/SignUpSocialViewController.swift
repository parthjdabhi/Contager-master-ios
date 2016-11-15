//
//  SignUpSocialViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/27/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit
import OAuthSwift


class SignUpSocialViewController: UIViewController {
    
    @IBOutlet var facebook: UIButton!
    @IBOutlet var twitter: UIButton!
    @IBOutlet var instagram: UIButton!
    @IBOutlet var linkedIn: UIButton!
    
    static var firstName = ""
    static var lastName = ""
    static var email = ""
    static var password = ""
    static var phone = ""
    static var picture = ""
    
    var instagramHandle = ""
    
    var facebookData: Dictionary<String, AnyObject>?
    var twitterData: Dictionary<String, AnyObject>?
    var instagramData: Dictionary<String, AnyObject>?
    var linkedinData: Dictionary<String, AnyObject>?
    
    var fbId: String?
    var twitterId: String?
    var instagramId: String?
    var linkedinId: String?
    
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    var oauthswiftInsta = OAuth2Swift(
        consumerKey:    "830c6697c41a49e0b99a49816a7d573c",
        consumerSecret: "fe6ed06f37bf47c59dff4e6f7d7f1281",
        authorizeUrl:   "https://api.instagram.com/oauth/authorize",
        //responseType:   "token",
        // or
        accessTokenUrl: "https://api.instagram.com/oauth/access_token",
        responseType:   "code"
    )
    
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func facebookLogin(sender: AnyObject)
    {
        let manager = FBSDKLoginManager()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error.localizedDescription)
            }
            else if result.isCancelled {
                print("Facebook login cancelled")
            }
            else {
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information...")
                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,first_name,last_name,email,gender,friends,picture"])
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    CommonUtils.sharedUtils.hideProgress()
                    if ((error) != nil) {
                        // Process error
                        print("Error: \(error)")
                    } else {
                        print("fetched user: \(result)")
                        self.fbId = result.valueForKey("id") as? String
                        self.facebookData = ["userId": result.valueForKey("id") as? String ?? "","userFirstName": result.valueForKey("first_name") as? String ?? "", "userLastName": result.valueForKey("last_name") as? String ?? "", "gender": result.valueForKey("gender") as? String ?? "", "email": result.valueForKey("email") as? String ?? ""]
                        print("Facebook Integration Data : \(self.facebookData)")
                        
                        if let picture = result.objectForKey("picture") {
                            if let pictureData = picture.objectForKey("data"){
                                if let pictureURL = pictureData.valueForKey("url") {
                                    print(pictureURL)
                                    self.facebookData?["profilePhotoURL"] = pictureURL
                                    //self.ref.child("users").child(self.user!.uid).child("facebookData").child("profilePhotoURL").setValue(pictureURL)
                                }
                            }
                        }
                        self.facebook.setTitle("Facebook Added", forState: .Normal)
                        self.facebook.enabled = false
                    }
                })
            }
        }
    }
    
    @IBAction func twitterLogin(sender: AnyObject)
    {
        let manager = Twitter()
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        manager.logInWithViewController(self) { (session, error) in
            CommonUtils.sharedUtils.hideProgress()
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading Information....")
                let client = TWTRAPIClient.clientWithCurrentUser()
                let request = client.URLRequestWithMethod("GET",
                    URL: "https://api.twitter.com/1.1/account/verify_credentials.json",
                    parameters: ["include_email": "true", "skip_status":"true"],
                    error: nil)
                
                client.sendTwitterRequest(request){ (response, data, connectionError) -> Void in
                    CommonUtils.sharedUtils.hideProgress()
                    let profile = try! NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    print(profile)
                    
                    self.twitterId = profile.valueForKey("id_str") as? String
                    self.twitterData = ["userId": profile.valueForKey("id_str")  as? String ?? "","userFirstName": profile.valueForKey("name") as? String ?? "", "userLastName": profile.valueForKey("screen_name") as? String ?? ""]
                    print("twitterData : \(self.twitterData)")
                    
                    //self.ref.child("users").child(self.user!.uid).child("twitterData").setValue(["userId": profile.valueForKey("id_str")  as? String ?? "","userFirstName": profile.valueForKey("name") as? String ?? "", "userLastName": profile.valueForKey("screen_name") as? String ?? ""])
                    self.twitter.setTitle("Twitter Added", forState: .Normal)
                    self.twitter.enabled = false
                }
            }
        }
    }
    
    @IBAction func instagramLogin(sender: AnyObject) {
        
        /*
        //cc78516e657b4c32ad4907bd8411d8e1
        //5958fbe586c443b7946cdf3c2f7283ec
        
        //let callback_new = "http://www.parthjdabhi.com/oauth_callback"
        let callback_new1 = "http://oauthswift.herokuapp.com/callback/Snagged"
        //let callback_new1 = "http://oauthswift.herokuapp.com/callback/instagram"

//        let callback_old = "Snagged://Snagged"
//        let oauthswift1 = OAuth2Swift(
//            //Old
//            //consumerKey:    "af9350fa8abd45af978145b4c896359e",
//            //consumerSecret: "632160631a534b808b2feb4389819acf",
//            //New Parth
//            consumerKey:    "cc78516e657b4c32ad4907bd8411d8e1",
//            consumerSecret: "5958fbe586c443b7946cdf3c2f7283ec",
//            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
//            // responseType:   "token"
//            // or
//            accessTokenUrl: "https://api.instagram.com/oauth/access_token",
//            responseType:   "code"
//        )
        
        //https://www.instagram.com/oauth/authorize/?client_id=830c6697c41a49e0b99a49816a7d573c&redirect_uri=http://oauthswift.herokuapp.com/callback/instagram&response_type=token
        //http://oauthswift.herokuapp.com/callback/instagram?test=data
        //https://connectapp.wordpress.com
        
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        let state: String = generateStateWithLength(20) as String
        oauthswiftInsta.authorizeWithCallbackURL( NSURL(string: callback_new1)!, scope: "likes+comments", state:state, success: {
                credential, response, parameters in
                let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(self.oauthswiftInsta.client.credential.oauth_token)"
                let parameters :Dictionary = Dictionary<String, AnyObject>()
                self.oauthswiftInsta.client.get(url, parameters: parameters,
                    success: {
                        data, response in
                        let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                        let mainDict = jsonDict.objectForKey("data") as! NSDictionary!
                        
                        self.instagramId = mainDict?.valueForKey("id") as? String
                        self.instagramData = ["userId": mainDict?.valueForKey("id") as? String ?? "","fullName": mainDict?.valueForKey("full_name") as? String ?? "", "profile_picture": mainDict?.valueForKey("profile_picture") as? String ?? "", "username": mainDict?.valueForKey("username") as? String ?? ""]
                        print("instagramData : \(self.instagramData)")
                        
                        //self.ref.child("users").child(self.user!.uid).child("instagramData").setValue(["userId": mainDict?.valueForKey("id") as? String ?? "","fullName": mainDict?.valueForKey("full_name") as? String ?? "", "profile_picture": mainDict?.valueForKey("profile_picture") as? String ?? "", "username": mainDict?.valueForKey("username") as? String ?? ""])
                        
                        self.instagram.setTitle("Instagram Added", forState: .Normal)
                        self.instagram.enabled = false
                        CommonUtils.sharedUtils.hideProgress()
                        
                    }, failure: { error in
                        print(error)
                        CommonUtils.sharedUtils.hideProgress()
                })
            }, failure: { error in
                CommonUtils.sharedUtils.hideProgress()
                print(error.localizedDescription)
        })
        */
        
        let alertController = UIAlertController(title: "Instagram", message: "Add Your Instagram Handle", preferredStyle: UIAlertControllerStyle.Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            print(firstTextField)
            self.instagramHandle = firstTextField.text! as String
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Contager"
        }
        /*
        alertController.addTextFieldWithConfigurationHandler { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Second Name"
        }*/
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func linkedInLogin(sender: AnyObject) {
        let oauthswift = OAuth1Swift(
            consumerKey:    "781k8vbvg9p34i",
            consumerSecret: "uDL7nlVXQ2XmB71N",
            requestTokenUrl: "https://api.linkedin.com/uas/oauth/requestToken",
            authorizeUrl:    "https://api.linkedin.com/uas/oauth/authenticate",
            accessTokenUrl:  "https://api.linkedin.com/uas/oauth/accessToken"
        )
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        oauthswift.authorizeWithCallbackURL( NSURL(string: "Snagged://Snagged/linkedin")!, success: {
            credential, response, parameters in
                oauthswift.client.get("https://api.linkedin.com/v1/people/~", parameters: [:],
                    success: {
                        data, response in
                        print(data)
                        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
                        print(dataString)
                        do {
                            let xmlDoc = try AEXMLDocument(xmlData: data)
                            
                            self.linkedinId = xmlDoc.root["id"].value
                            
                            self.linkedinData = Dictionary()
                            self.linkedinData?["userId"] = xmlDoc.root["id"].value ?? ""
                            self.linkedinData?["userFirstName"] = xmlDoc.root["first-name"].value ?? ""
                            self.linkedinData?["userlastName"] = xmlDoc.root["last-name"].value ?? ""
                            self.linkedinData?["headline"] = xmlDoc.root["headline"].value ?? ""
                            self.linkedinData?["url"] = xmlDoc.root["site-standard-profile-request"]["url"].value ?? ""
                            
                            //self.linkedinData = ["userId": xmlDoc.root["id"].value ?? "", "userFirstName": xmlDoc.root["first-name"].value ?? "", "userlastName": xmlDoc.root["last-name"].value ?? "", "headline": xmlDoc.root["headline"].value ?? "", "url": xmlDoc.root["site-standard-profile-request"]["url"].value ?? ""]
                            
                            //self.ref.child("users").child(self.user!.uid).child("linkedinData").setValue(["userId": xmlDoc.root["id"].value ?? "", "userFirstName": xmlDoc.root["first-name"].value ?? "", "userlastName": xmlDoc.root["last-name"].value ?? "", "headline": xmlDoc.root["headline"].value ?? "", "url": xmlDoc.root["site-standard-profile-request"]["url"].value ?? ""])
                            
                            print("linkedinData : \(self.linkedinData)")
                            
                            self.linkedIn.setTitle("Linkedin Added", forState: .Normal)
                            self.linkedIn.enabled = false
                            CommonUtils.sharedUtils.hideProgress()
                        }
                        catch{
                            
                        }
                    }, failure: { error in
                        print(error)
                        CommonUtils.sharedUtils.hideProgress()
                })
            }, failure: { error in
                CommonUtils.sharedUtils.hideProgress()
                print(error.localizedDescription)
        })
    }
    
    @IBAction func createAccount(sender: AnyObject)
    {
        let emailInfo : String = String(SignUpSocialViewController.email)
        let passwordInfo : String = String(SignUpSocialViewController.password)
        let firstNameInfo : String = String(SignUpSocialViewController.firstName)
        let lastNameInfo : String = String(SignUpSocialViewController.lastName)
        let userPicture : String = String(SignUpSocialViewController.picture)
        let userPhone : String = String(SignUpSocialViewController.phone)
        
        print(userPhone)
        print(emailInfo)
        print(passwordInfo)
        print(firstNameInfo)
        print(lastNameInfo)
        print(userPicture)
        
        if userPicture == "" {
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Please select the photo")
        }
        else if emailInfo != ""
            && passwordInfo != ""
            && userPhone != ""
            && userPicture != ""
            && firstNameInfo != ""
            && lastNameInfo != ""
        {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(emailInfo, password: passwordInfo, completion:  { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credentialWithEmail(emailInfo, password: passwordInfo)
                    
                    var userDetail = Dictionary<String, AnyObject>()
                    userDetail["userFirstName"] = firstNameInfo
                    userDetail["userLastName"] = lastNameInfo
                    userDetail["userPhone"] = userPhone
                    userDetail["email"] = emailInfo
                    userDetail["instagram"] = "\(self.instagramHandle)"
                    
                    if self.facebookData != nil {
                        userDetail["facebookData"] = self.facebookData
                        userDetail["fbId"] = self.fbId
                    }
                    if self.twitterData != nil {
                        userDetail["twitterData"] = self.twitterData
                        userDetail["twitterId"] = self.twitterId
                    }
                    if self.instagramData != nil {
                        userDetail["instagramData"] = self.instagramData
                        userDetail["instagramId"] = self.instagramId
                    }
                    if self.linkedinData != nil {
                        userDetail["linkedinData"] = self.linkedinData
                        userDetail["linkedinId"] = self.linkedinId
                    }
                    
                    userDetail["deviceToken"] = NSUserDefaults.standardUserDefaults().objectForKey("deviceToken") as? String ?? ""
                    
                    print("userDetail : \(userDetail)")
                    
                    self.ref.child("users").child(user!.uid).setValue(userDetail)
                    
//                    if userPicture == "" {
//                        CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Please select the photo")
//                        return
//                    }
                    self.ref.child("users").child(user!.uid).child("image").setValue(userPicture)
                    CommonUtils.sharedUtils.hideProgress()
                    let mainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainScreenViewController") as! MainScreenViewController!
                    self.navigationController?.pushViewController(mainViewController, animated: true)
                } else {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        CommonUtils.sharedUtils.hideProgress()
                        CommonUtils.sharedUtils.showAlert(self, title: "Error", message: (error?.localizedDescription)!)
                    })
                }
            })
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill out all fields!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
        }
    }
    
}
