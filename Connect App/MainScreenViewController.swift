//
//  MainScreenViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/22/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

class MainScreenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var lblFriendReqBadge: UILabel!
    @IBOutlet var lblUnreadConBadge: UILabel!
    @IBOutlet var image1: UIImageView!
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    override func viewDidLoad() {
        
        //FIRCrashMessage("Cause Crash button clicked")
        //fatalError()
        
        lblFriendReqBadge.backgroundColor = UIColor.redColor()
        lblFriendReqBadge.layer.borderWidth = 1
        lblFriendReqBadge.layer.masksToBounds = true
        lblFriendReqBadge.layer.borderColor = UIColor.whiteColor().CGColor
        lblFriendReqBadge.layer.cornerRadius = lblFriendReqBadge.frame.height/2
        
        if AppState.friendReqCount != 0 {
            lblFriendReqBadge.text = String(format: "%d",AppState.friendReqCount)
            lblFriendReqBadge.hidden = false
        } else {
            lblFriendReqBadge.hidden = true
        }
        
        lblUnreadConBadge.backgroundColor = UIColor.redColor()
        lblUnreadConBadge.layer.borderWidth = 1
        lblUnreadConBadge.layer.masksToBounds = true
        lblUnreadConBadge.layer.borderColor = UIColor.whiteColor().CGColor
        lblUnreadConBadge.layer.cornerRadius = lblUnreadConBadge.frame.height/2
        
        if AppState.friendReqCount != 0 {
            lblUnreadConBadge.text = String(format: "%d",AppState.friendReqCount)
            lblUnreadConBadge.hidden = false
        } else {
            lblUnreadConBadge.hidden = true
        }
        
        //try! FIRAuth.auth()?.signOut()
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observeEventType(.Value, withBlock: { (snapshot) in
            AppState.sharedInstance.currentUser = snapshot
            if let base64String = snapshot.value!["image"] as? String {
                // decode image
                self.image1.image = CommonUtils.sharedUtils.decodeImage(base64String)
            } else {
                if let facebookData = snapshot.value!["facebookData"] as? [String : String] {
                    if let image_url = facebookData["profilePhotoURL"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.image1.sd_setImageWithURL(url)
                    }
                } else if let twitterData = snapshot.value!["twitterData"] as? [String : String] {
                    if let image_url = twitterData["profile_image_url"]  {
                        print(image_url)
                        let image_url_string = image_url
                        let url = NSURL(string: "\(image_url_string)")
                        self.image1.sd_setImageWithURL(url)
                    }
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        image1.layer.borderWidth = 2
        image1.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    /*
     @IBAction func openCameraButton(sender: AnyObject) {
     
     if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
     let imagePicker = UIImagePickerController()
     imagePicker.delegate = self
     imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
     imagePicker.allowsEditing = false
     self.presentViewController(imagePicker, animated: true, completion: nil)
     }
     }
     
     @IBAction func openPhotoLibraryButton(sender: AnyObject) {
     
     if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
     let imagePicker = UIImagePickerController()
     imagePicker.delegate = self
     imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
     imagePicker.allowsEditing = true
     self.presentViewController(imagePicker, animated: true, completion: nil)
     }
     
     }
     
     @IBAction func saveButton(sender: AnyObject) {
     
     let imageData = UIImageJPEGRepresentation(image1.image!, 0.6)
     let compressedJPGImage = UIImage(data: imageData!)
     UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
     
     let alert = UIAlertView(title: "Wow", message: "This is your new Snagged photo!", delegate: nil, cancelButtonTitle: "Ok")
     alert.show()
     
     }*/
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateFriendRequestsCount()
        self.updateUnreadRecentChatsCount()
    }
    
    func updateFriendRequestsCount() {
        
        if AppState.friendReqCount != 0 {
            self.lblFriendReqBadge.text = String(format: "%d",AppState.friendReqCount)
            self.lblFriendReqBadge.hidden = false
        } else {
            self.lblFriendReqBadge.hidden = true
        }
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        let ref = self.ref.child("users").child(userId!).child("friendRequests")
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            AppState.friendReqCount = snapshot.children.allObjects.count
            if AppState.friendReqCount != 0 {
                self.lblFriendReqBadge.text = String(format: "%d",AppState.friendReqCount)
                self.lblFriendReqBadge.hidden = false
            } else {
                self.lblFriendReqBadge.hidden = true
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    
    func updateUnreadRecentChatsCount() {
        
        let firstGroup = dispatch_group_create()
        var recents: [AnyObject] = []
        var recentIds: [AnyObject] = []
        var unreadConversionCount = 0
        var unreadMsgCount = 0
        
        let userID = FIRAuth.auth()?.currentUser?.uid ?? ""
        let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FRECENT_PATH)
        dispatch_group_enter(firstGroup)
        firebase.queryOrderedByChild(FRECENT_USERID).queryEqualToValue(userID).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            if snapshot.exists() {
                recents.removeAll()
                //Sort array by dict[FRECENT_UPDATEDAT]
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print(rest.value)
                    if let dic = rest.value as? [String:AnyObject] {
                        print("Conversation : \(dic)")
                        recents.append(dic)
                        recentIds.append(dic[FRECENT_GROUPID] as? String ?? "")
                        
                        let GroupId = dic[FRECENT_GROUPID] as? String ?? ""
                        let firebase2: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FMESSAGE_PATH).child(GroupId)
                        
                        
                        let OppUserId = dic[FRECENT_OPPUSERID] as? String ?? ""
                        dispatch_group_enter(firstGroup)
                        
                        firebase2.queryOrderedByChild(FMESSAGE_STATUS).queryEqualToValue(TEXT_DELIVERED).observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
                            if snapshot.exists() {
                                print(snapshot.childrenCount)
                                let enumerator = snapshot.children
                                var UnreadMsgCount = 0
                                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                                    print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                                    if var dic = rest.value as? [String:AnyObject] where (dic[FRECENT_USERID] as? String ?? "") ==  OppUserId {
                                        print(rest.key)
                                        print("Conversation : \(dic)")
                                        UnreadMsgCount += 1
                                    }
                                }
                                if UnreadMsgCount != 0 {
                                    unreadConversionCount += 1
                                    unreadMsgCount += UnreadMsgCount
                                }
                            }
                            dispatch_group_leave(firstGroup)
                        })
                    }
                }
            }
            dispatch_group_leave(firstGroup)
            //createRecentObservers
        })
        
        
        dispatch_group_notify(firstGroup, dispatch_get_main_queue()) {
            AppState.unreadConversionCount =  unreadConversionCount
            AppState.unreadConversionCount =  unreadConversionCount
            if AppState.unreadConversionCount != 0 {
                self.lblUnreadConBadge.text = String(format: "%d",AppState.unreadConversionCount)
                self.lblUnreadConBadge.hidden = false
            } else {
                self.lblUnreadConBadge.hidden = true
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        image1.image = image
        //self.dismissViewControllerAnimated(true, completion: nil);
        self.navigationController?.popViewControllerAnimated(true)  //Changed to Push
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func selectPotalView(sender: AnyObject) {        
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PortalViewController") as! PortalViewController!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectContactsSocialView(sender: AnyObject) {
        
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("NoteViewController") as! NoteViewController!
        self.navigationController?.pushViewController(vc, animated: true)
        /*
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ContactSocialViewController") as! ContactSocialViewController!
        self.navigationController?.pushViewController(vc, animated: true)
        */
    }
    
    @IBAction func btnRecentChat(sender: AnyObject) {
        
        let recentChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RecentChatViewController") as! RecentChatViewController!
        self.navigationController?.pushViewController(recentChatViewController, animated: true)
        
    }
}