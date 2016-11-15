//
//  FriendPortalViewController.swift
//  Connect App
//
//  Created by devel on 7/12/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import MessageUI
import Foundation
import Firebase
import SDWebImage
import CryptoSwift

class FriendPortalViewController: UIViewController {
    
    @IBOutlet var noteOnlyLabel: UILabel!
    @IBOutlet var nameNoteLabel: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var noteOptionBtn: UIButton!
    @IBOutlet weak var btnStartChat: UIButton!
    
    var selectedUserId: String?
    var ref:FIRDatabaseReference!
    var filtered:[NoteData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        optionView.hidden = true
        noteOptionBtn.hidden = false
        //btnStartChat.hidden = true
        
        ref = FIRDatabase.database().reference()
        self.noteOnlyLabel.text = ""
        
        if let friend = AppState.sharedInstance.friend {
            let name = friend.userName
            self.nameNoteLabel.text = name
            
            self.noteOnlyLabel.text = ""
            let imageExist = friend.imageExist()
            if imageExist {
                let image = friend.getImage()
                self.image.image = image
            } else {
                if !friend.getUserPhotoURL().isEmpty {
                    self.image.sd_setImageWithURL(NSURL(string: friend.getUserPhotoURL()), placeholderImage: UIImage(named: "no-pic.png"))
                }
            }
            
            // Check the note of current user`s snapshot data
            let friendId = friend.getUid()
            let userID = FIRAuth.auth()?.currentUser?.uid
            let noteRef = ref.child("users").child(userID!).child("notes")
            noteRef.observeEventType(.Value, withBlock: { (snapshot) in
                for childSnap in snapshot.children.allObjects {
                    let snap = childSnap as! FIRDataSnapshot
                    let dic = snap.value as! [String : String]
                    for (key, value) in dic {
                        if key == friendId {
                            self.noteOnlyLabel.text = value
                        }
                    }
                }
            })
        }
        
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    @IBAction func NoteOptionFunc(sender: AnyObject) {
        self.noteOptionBtn.hidden = true
        optionView.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ref = FIRDatabase.database().reference()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func editNoteButton(sender: AnyObject) {
        optionView.hidden = true
        noteOptionBtn.hidden = false
        if let friend = AppState.sharedInstance.friend {
            selectedUserId = friend.getUid()
            AddNoteViewController.selectedUserID = selectedUserId
            AddNoteViewController.editNoteText = self.noteOnlyLabel.text
            AppState.sharedInstance.friend = friend
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddNoteViewController") as! AddNoteViewController!
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func deleteNoteButton(sender: AnyObject) {
        optionView.hidden = true
        noteOptionBtn.hidden = false
        if let friend = AppState.sharedInstance.friend {
            
            let alert = UIAlertController(title: "Confirm", message: "Do you want to really delete Note?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: { action in
                //self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController?.popViewControllerAnimated(true)  //Changed to Push
                self.noteOnlyLabel.text = ""
                self.selectedUserId = friend.getUid()
                // delete NOTE                
                let userID = FIRAuth.auth()?.currentUser?.uid
                let ref = self.ref.child("users").child(userID!)
                let dic = [AddNoteViewController.selectedUserID! : self.noteOnlyLabel.text!] as [String:String]
                ref.child("notes").childByAutoId().setValue(dic)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func contactButton(sender: AnyObject) {
        self.performSegueWithIdentifier("FriendProfileContacts", sender: self)
    }
    
    @IBAction func addNoteButton(sender: AnyObject) {
        optionView.hidden = true
        noteOptionBtn.hidden = false
        if let friend = AppState.sharedInstance.friend {
        selectedUserId = friend.getUid()
        AddNoteViewController.selectedUserID = selectedUserId
        AddNoteViewController.editNoteText = ""
        AppState.sharedInstance.friend = friend
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddNoteViewController") as! AddNoteViewController!
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func socialButton(sender: AnyObject) {
        self.performSegueWithIdentifier("FriendSocialMedia", sender: self)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnStartChat(sender: AnyObject) {
        
        let groupId = self.StartPrivateChat(AppState.sharedInstance.friend?.getUid() ?? "", Usersname: AppState.sharedInstance.friend?.userName ?? "")
        
        let chatVc = self.storyboard?.instantiateViewControllerWithIdentifier("MyChatViewController") as! MyChatViewController!
        chatVc.groupId = groupId
        chatVc.senderDisplayName = AppState.sharedInstance.friend?.userName ?? ""
        chatVc.senderId = FIRAuth.auth()?.currentUser?.uid
        chatVc.OppUserId = AppState.sharedInstance.friend?.getUid() ?? ""
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.pushViewController(chatVc, animated: true)
    }
    
    //StartPrivateChat
    func StartPrivateChat(userID:String,Usersname:String) -> String
    {
        let userId1 = (FIRAuth.auth()?.currentUser?.uid)! as String
        let userId2 = userID //self.objectsID.objectAtIndex(0) as? String ?? ""      //Later Change it to dynamic
        let user1Name = "user1"
        let user2Name = "user2"//user2[FUSER_NAME]
        
        let members:[String] = NSArray.init(array:[userId1,userId2]) as! [String]
        let sortedMembers = members.sort({ $0 < $1 })
        
        let groupId =  (sortedMembers.joinWithSeparator("")).md5()
        
        print("Group ID : \(groupId)")
        
        CreateRecent(userId1, oppUserId:userId2, groupId: groupId, members: members, description: user2Name);
        CreateRecent(userId2, oppUserId:userId1, groupId: groupId, members: members, description: user1Name);
        
        return groupId;
    }
    
    func CreateRecent(userId:String,oppUserId:String,groupId:String ,members:[String] ,description:String)
    {
        let firebase: FIRDatabaseReference = FIRDatabase.database().referenceWithPath(FRECENT_PATH)
        let query: FIRDatabaseQuery = firebase.queryOrderedByChild(FRECENT_GROUPID).queryEqualToValue(groupId)
        query.observeSingleEventOfType(.Value, withBlock: {(snapshot: FIRDataSnapshot) -> Void in
            var create: Bool = true
            if snapshot.exists() {
                print(snapshot.childrenCount) // I got the expected number of items
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    print(rest.value)
                    if let dictionary = rest.value as? [NSString : AnyObject]
                        where (dictionary[FRECENT_USERID] as! String) == userId
                    {
                        create = false
                    }
                }
            }
            if create == true {
                self.CreateRecentItem(userId, oppUserId:oppUserId, groupId: groupId, members: members, description: description)
            }
        })
    }
    
    func CreateRecentItem(userId:String ,oppUserId:String ,groupId:String ,members:[String] ,description:String)
    {
        var recent: [String:AnyObject] =  Dictionary()
        recent[FRECENT_USERID] = userId
        recent[FRECENT_OPPUSERID] = oppUserId
        recent[FRECENT_GROUPID] = groupId
        recent[FRECENT_MEMBERS] = members
        recent[FRECENT_DESCRIPTION] = ""
        recent[FRECENT_LASTMESSAGE] = ""
        recent[FRECENT_COUNTER] = 0
        recent[FRECENT_TYPE] = "Private"
        
        recent[FRECENT_NAME] = (userId == FIRAuth.auth()?.currentUser?.uid ?? "") ? "Me" : AppState.sharedInstance.friend?.userName ?? "";
        
        recent[FRECENT_UPDATEDAT] = NSDate().customFormatted
        recent[FRECENT_CREATEDAT] = NSDate().customFormatted
        
        ref.child(FRECENT_PATH).childByAutoId().updateChildValues(recent) { (error, FIRDBRef) in
            if error == nil {
                print("saved recent object")
            } else {
                print("Failed to save recent object : \(recent)")
            }
        }
        
    }
}