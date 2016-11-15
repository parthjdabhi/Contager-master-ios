//
//  LoginViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/22/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import Twitter
import TwitterKit

class LoginViewController: UIViewController {

    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var twitterButton: UIButton!
    
    @IBOutlet var passwordField: UITextField!
    
    @IBAction func LogIn(sender: AnyObject) {
        
        let email = self.emailField.text!
        let password = self.passwordField.text!
        
        if email != "" && password != "" {
            
            FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in if error == nil {

                self.performSegueWithIdentifier("MainScreenLogIn", sender: self)
                
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
    
    @IBAction func facebookLoginButton(sender: AnyObject) {
        
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
                        self.performSegueWithIdentifier("MainScreenLogIn", sender: self)
                    }
                })
            }
        }
    }
    
    @IBAction func loginWithTwitter(sender: AnyObject) {
        
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
                        self.performSegueWithIdentifier("MainScreenLogIn", sender: self)
                    }
                })
            }
        }
        
    }

    
}
