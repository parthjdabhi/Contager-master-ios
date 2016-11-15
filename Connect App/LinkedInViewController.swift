//
//  LinkedInViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/22/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit

class LinkedInViewController: UIViewController {
    
    @IBOutlet var btnSignIn: UIButton!
    @IBOutlet var btnGetProfileInfo: UIButton!
    @IBOutlet var btnOpenProfile: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnSignIn.enabled = true
        btnGetProfileInfo.enabled = false
        btnOpenProfile.hidden = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForExistingAccessToken()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getProfileInfo(sender: AnyObject) {
        
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") {
            // Specify the URL string that we'll get the profile info from.
            let targetURLString = "https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json"
            
            
            // Initialize a mutable URL request object.
            let request = NSMutableURLRequest(URL: NSURL(string: targetURLString)!)
            
            // Indicate that this is a GET request.
            request.HTTPMethod = "GET"
            
            // Add the access token as an HTTP header field.
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            // Initialize a NSURLSession object.
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
            // Make the request.
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    // Convert the received JSON data into a dictionary.
                    do {
                        let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        
                        let profileURLString = dataDictionary["publicProfileUrl"] as! String
                        
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.btnOpenProfile.setTitle(profileURLString, forState: UIControlState.Normal)
                            self.btnOpenProfile.hidden = false
                            
                        })
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }

        
    }
    
    @IBAction func openProfileInSafari(sender: AnyObject) {
        
        let profileURL = NSURL(string: btnOpenProfile.titleForState(UIControlState.Normal)!)
        UIApplication.sharedApplication().openURL(profileURL!)
        
    }
    
    func checkForExistingAccessToken() {
        if NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") != nil {
            btnSignIn.enabled = false
            btnGetProfileInfo.enabled = true
        }
    }

}
