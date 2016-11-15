//
//  SignUpViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/22/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import TwitterKit
import Twitter
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit

class SignUpViewController: UIViewController {
    
    @IBOutlet var emailField: UITextField!
    
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    
    
    
    @IBAction func createButton(sender: AnyObject) {
        
        let email = self.emailField.text!
        let password = self.passwordField.text!
        
        // make sure the user entered both email & password
        if email != "" && password != "" {
            
            FIRAuth.auth()?.createUserWithEmail(email, password: password, completion:  { (user, error) in if error == nil {
                
                FIREmailPasswordAuthProvider.credentialWithEmail(email, password: password)
                self.dismissViewControllerAnimated(true, completion: nil)
                
                self.performSegueWithIdentifier("MainScreenSignUp", sender: self)
                
            } else {
                
                print(error)
                }
                
                
                })
            
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Enter email & password!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func Cancel(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            performSegueWithIdentifier(Constants.Segues.FpToSignIn, sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }

    }
    
    
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
    
    @IBAction func facebookSignUp(sender: AnyObject) {
        
        let manager = FBSDKLoginManager()
        manager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self) { (result, error) in
            if error != nil {
                print(error.localizedDescription)
            }
            else if result.isCancelled {
                print("Facebook login cancelled")
            }
            else {
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                
                let credential = FIRFacebookAuthProvider.credentialWithAccessToken(token)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    else {
                        self.performSegueWithIdentifier("MainScreenSignUp", sender: self)
                    }
                })
            }
        }
        
    }
    
    @IBAction func twitterSignUp(sender: AnyObject) {
        
        let manager = Twitter()
        
        manager.logInWithViewController(self) { (session, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            else {
                let token = session!.authToken
                let secret = session!.authTokenSecret
                
                let credential = FIRTwitterAuthProvider.credentialWithToken(token, secret: secret)
                FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    else {
                        self.performSegueWithIdentifier("MainScreenSignUp", sender: self)
                    }
                })
            }
        }
        
    }
    

}
