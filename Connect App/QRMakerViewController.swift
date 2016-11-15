//
//  QRMakerViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/30/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase
import QRCode

class QRMakerViewController: UIViewController {

   
    @IBOutlet var qrSnagged: UIImageView!
    @IBOutlet var qrFacebook: UIImageView!
    @IBOutlet var qrLinkedIn: UIImageView!
    @IBOutlet var qrInstagram: UIImageView!
    @IBOutlet var qrTwitter: UIImageView!
    @IBOutlet var userDetails: UILabel!
    var ref:FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        print("userid", userID)
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let facebookData = snapshot.value!["facebookData"]{
                let facebookDictionary = facebookData as? NSDictionary?
                if facebookData == nil {
                    let noInformation = "No Information"
                    self.qrFacebook.image = {
                        var qrCode = QRCode("\(noInformation)")
                        qrCode!.size = self.qrFacebook.bounds.size
                        qrCode!.color = CIColor(rgba: "55FBC1")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()
                } else {
                    let facebookFirstName = facebookDictionary!!["userFirstName"] as! String!
                    let facebookLastName = facebookDictionary!!["userLastName"] as! String!
                    let facebookEmail = facebookDictionary!!["email"] as! String!
                    let facebookGender = facebookDictionary!!["gender"] as! String!
                    
                    self.qrFacebook.image = {
                        var qrCode = QRCode("\(facebookFirstName), \(facebookLastName), \(facebookEmail), \(facebookGender)")
                        qrCode!.size = self.qrFacebook.bounds.size
                        qrCode!.color = CIColor(rgba: "55FBC1")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()}
            }})
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let twitterData = snapshot.value!["twitterData"]{
                let twitterDictionary = twitterData as? NSDictionary?
                if twitterData == nil {
                    let noInformation = "No Information"
                    self.qrTwitter.image = {
                        var qrCode = QRCode("\(noInformation)")
                        qrCode!.size = self.qrTwitter.bounds.size
                        qrCode!.color = CIColor(rgba: "54FCFC")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()
                } else {
                    let twitterFirstName = twitterDictionary!!["userFirstName"] as! String!
                    let twitterLastName = twitterDictionary!!["userLastName"] as! String!
                    
                    self.qrTwitter.image = {
                        var qrCode = QRCode("\(twitterFirstName), \(twitterLastName)")
                        qrCode!.color = CIColor(rgba: "54FCFC")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.size = self.qrTwitter.bounds.size
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()}
            }
        })
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let linkedinData = snapshot.value!["linkedinData"]{
                let linkedinDictionary = linkedinData as? NSDictionary?
                if linkedinData == nil {
                    let noInformation = "No Information"
                    self.qrLinkedIn.image = {
                        var qrCode = QRCode("\(noInformation)")
                        qrCode!.size = self.qrLinkedIn.bounds.size
                        qrCode!.color = CIColor(rgba: "65FC54")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()
                } else {
                    let linkedinFirstName = linkedinDictionary!!["userFirstName"] as! String!
                    let linkedinLastName = linkedinDictionary!!["userLastName"] as! String!
                    let linkedinHeadline = linkedinDictionary!!["headline"] as! String!
                    
                    self.qrLinkedIn.image = {
                        var qrCode = QRCode("\(linkedinFirstName), \(linkedinLastName), \(linkedinHeadline)")
                        qrCode!.size = self.qrLinkedIn.bounds.size
                        qrCode!.color = CIColor(rgba: "65FC54")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()
                }}
        })
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        if let user = FIRAuth.auth()?.currentUser {
            let email = user.email
            let emailString = email as String?
            let displayName = user.displayName
            let displayNameString = displayName as String?
            if emailString == nil && displayNameString == nil {
                print("No email & no name")
            } else {
            self.qrSnagged.image = {
                var qrCode = QRCode("\(displayNameString), \(emailString)")
                qrCode!.size = self.qrSnagged.bounds.size
                qrCode!.color = CIColor(rgba: "A255FB")
                qrCode!.backgroundColor = CIColor(rgba: "000")
                qrCode!.errorCorrection = .High
                return qrCode!.image
            }()
            }
            }})
        ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let instagramData = snapshot.value!["instagramData"]{
                let instagramDictionary = instagramData as? NSDictionary?
                if instagramData == nil {
                    let noInformation = "No Information"
                    self.qrInstagram.image = {
                        var qrCode = QRCode("\(noInformation)")
                        qrCode!.size = self.qrInstagram.bounds.size
                        qrCode!.color = CIColor(rgba: "F80B0B")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()
                } else {
                    let instagramFullName = instagramDictionary!!["fullName"] as! String!
                    let instagramUsername = instagramDictionary!!["username"] as! String!
                    
                    self.qrInstagram.image = {
                        var qrCode = QRCode("\(instagramFullName), \(instagramUsername)")
                        qrCode!.color = CIColor(rgba: "F80B0B")
                        qrCode!.backgroundColor = CIColor(rgba: "000")
                        qrCode!.size = self.qrInstagram.bounds.size
                        qrCode!.errorCorrection = .High
                        return qrCode!.image
                    }()
                }}
            })
        { (error) in
            print(error.localizedDescription)
        }
    }
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backBtnTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}


