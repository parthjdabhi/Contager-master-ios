//
//  SettingsViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 7/3/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import TwitterKit
import FBSDKLoginKit
import FBSDKCoreKit
import OAuthSwift

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var facebook: UIButton!
    @IBOutlet var twitter: UIButton!
    @IBOutlet var instagram: UIButton!
    @IBOutlet var linkedIn: UIButton!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var phoneField: UITextField!
    @IBOutlet weak var friendRequests: UILabel!
    
    var instagramHandle = ""
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendRequests.backgroundColor = UIColor.redColor()
        friendRequests.layer.borderWidth = 1
        friendRequests.layer.masksToBounds = true
        friendRequests.layer.borderColor = UIColor.whiteColor().CGColor
        friendRequests.layer.cornerRadius = friendRequests.frame.height/2
    }
    
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        self.firstNameField.delegate = self
        self.lastNameField.delegate = self
        self.emailField.delegate = self
        self.phoneField.delegate = self
        self.friendRequests.hidden = true
        
        //Mark check inbox
        checkInbox()
        
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func facebookLogin(sender: AnyObject) {
        
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
                        var facebookData = Dictionary<String, String>()
                        facebookData["userId"] = result.valueForKey("id") as? String ?? ""
                        facebookData["userFirstName"] = result.valueForKey("first_name") as? String ?? ""
                        facebookData["userLastName"] = result.valueForKey("last_name") as? String ?? ""
                        facebookData["gender"] = result.valueForKey("gender") as? String ?? ""
                        facebookData["email"] = result.valueForKey("email") as? String ?? ""
                        
                        if let picture = result.objectForKey("picture") {
                            if let pictureData = picture.objectForKey("data"){
                                if let pictureURL = pictureData.valueForKey("url") as? String {
                                    print(pictureURL)
                                    facebookData["profilePhotoURL"] = pictureURL
                                }
                            }
                        }
                        
                        print("Facebook Integration Data : \(facebookData)")
                        //userDetail["fbId"] = self.fbId
                        self.ref.child("users").child(self.user!.uid).setValue(["facebookData": facebookData, "fbId" :result.valueForKey("id") as? String ?? ""])
                        self.facebook.titleLabel?.text = "Facebook Added"
                    }
                })
            }
        }
    }
    @IBAction func twitterLogin(sender: AnyObject) {
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
                    
                    self.ref.child("users").child(self.user!.uid).child("twitterData").setValue(["userFirstName": profile.valueForKey("name") as! String!, "userLastName": profile.valueForKey("screen_name") as! String!])
                    self.twitter.titleLabel?.text = "Twitter Added"
                }
            }
        }
    }
    @IBAction func instagramLogin(sender: AnyObject)
    {
        /*
        var oauthswift = OAuth2Swift(
            consumerKey:    "830c6697c41a49e0b99a49816a7d573c",
            consumerSecret: "fe6ed06f37bf47c59dff4e6f7d7f1281",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            //responseType:   "token",
            // or
            accessTokenUrl: "https://api.instagram.com/oauth/access_token",
            responseType:   "code"
        )
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Loading...")
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: "Snagged://Snagged")!, scope: "likes+comments", state:state, success: {
            credential, response, parameters in
            let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(oauthswift.client.credential.oauth_token)"
            let parameters :Dictionary = Dictionary<String, AnyObject>()
            oauthswift.client.get(url, parameters: parameters,
                success: {
                    data, response in
                    let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                    let mainDict = jsonDict.objectForKey("data") as! NSDictionary!
                    self.ref.child("users").child(self.user!.uid).child("instagramData").setValue(["fullName": mainDict?.valueForKey("full_name") as! String!, "profile_picture": mainDict?.valueForKey("profile_picture") as! String!, "username": mainDict?.valueForKey("username") as! String!])
                    self.linkedIn.titleLabel?.text = "Linkedin Added"
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
            self.ref.child("users").child(self.user!.uid).updateChildValues(["instagram": "\(self.instagramHandle)"])
            
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
                        self.ref.child("users").child(self.user!.uid).child("linkedinData").setValue(["userFirstName": xmlDoc.root["first-name"].value!, "userlastName": xmlDoc.root["last-name"].value!, "headline": xmlDoc.root["headline"].value!, "url": xmlDoc.root["site-standard-profile-request"]["url"].value!])
                        self.linkedIn.titleLabel?.text = "Linkedin Added"
                        CommonUtils.sharedUtils.hideProgress()
                    }
                    catch{
                        
                    }
                }, failure: { error in
                    print(error)
            })
            }, failure: { error in
                CommonUtils.sharedUtils.hideProgress()
                print(error.localizedDescription)
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createProfile(sender: AnyObject) {
        let email = self.emailField.text!
        // make sure the user entered both email & password
        if email != "" {
            CommonUtils.sharedUtils.showProgress(self.view, label: "Registering...")
            FIRAuth.auth()?.createUserWithEmail(email, password: "nil", completion:  { (user, error) in
                if error == nil {
                    FIREmailPasswordAuthProvider.credentialWithEmail(email, password: "nil")
                    self.ref.child("users").child(user!.uid).setValue(["userFirstName": self.firstNameField.text!, "userLastName": self.lastNameField.text!, "userPhoneNumber": self.phoneField.text!])
                    CommonUtils.sharedUtils.hideProgress()
                    let signUpSocialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpSocialViewController") as! SignUpSocialViewController!
                    self.navigationController?.pushViewController(signUpSocialViewController, animated: true)
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

    @IBAction func backButton(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func inboxButton(sender: UIButton) {
        self.performSegueWithIdentifier("SettingsToInbox", sender: self)
    }
    
    func checkInbox() -> Void {
        
        if AppState.friendReqCount != 0 {
            self.friendRequests.text = String(format: "%d",AppState.friendReqCount)
            self.friendRequests.hidden = false
        } else {
            self.friendRequests.hidden = true
        }
        
//        let userId = FIRAuth.auth()?.currentUser?.uid
//        let ref = self.ref.child("users").child(userId!).child("friendRequests")
//        
//        ref.observeEventType(.Value, withBlock: { snapshot in
//                let count = snapshot.children.allObjects.count
//                self.friendRequests.text = String(count)
//            
//                if count > 0 {
//                    self.friendRequests.hidden = false
//                } else {
//                    self.friendRequests.hidden = true
//                }
//            }, withCancelBlock: { error in
//                print(error.description)
//        })
        
        
    }
    
    @IBAction func logOutButton(sender: AnyObject) {
        
        try! FIRAuth.auth()?.signOut()
        AppState.sharedInstance.signedIn = false
        
//        var storyboard = UIStoryboard()
//        storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("FirebaseSignInViewController")
//        
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
