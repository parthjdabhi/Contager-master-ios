//
//  AddNoteViewController.swift
//  Connect App
//
//  Created by Admin on 7/17/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class AddNoteViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var ref: FIRDatabaseReference!
    static var selectedUserID: String?
    static var editNoteText: String?
    @IBOutlet weak var noteField: UITextView!
    @IBOutlet var mytex : UITextField!
    @IBOutlet weak var nameNoteLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var svContent: UIScrollView!
    @IBOutlet weak var viewContent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.mytex.delegate = self;
        //print("selectedUserID: \(selectedUserID)")
        ref = FIRDatabase.database().reference()
        noteField.delegate = self
        
        if let friend = AppState.sharedInstance.friend {
            self.nameNoteLabel.textColor = UIColor.whiteColor()
            let name = friend.userName
            self.nameNoteLabel.text = name
            if !(AddNoteViewController.editNoteText?.isEmpty)! {
                self.noteField.text = AddNoteViewController.editNoteText
            }
            let imageExist = friend.imageExist()
            if imageExist {
                let image = friend.getImage()
                self.image.image = image
            } else {
                if !friend.getUserPhotoURL().isEmpty {
                    self.image.sd_setImageWithURL(NSURL(string: friend.getUserPhotoURL()), placeholderImage: UIImage(named: "no-pic.png"))
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
    }
    
    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textViewDidBeginEditing(textField: UITextView) {
        self.svContent.setContentOffset(CGPointMake(0, 200), animated: true)
    }
    
    func textViewDidEndEditing(textField: UITextView) {
        self.svContent.setContentOffset(CGPointZero, animated: true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.endEditing(true)
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func onSaveNote(sender: UIButton) {
        if self.noteField.text == nil {
            CommonUtils.sharedUtils.showAlert(self, title: "Error", message: "Please input the note.")
        } else {
            let userID = FIRAuth.auth()?.currentUser?.uid
            let ref = self.ref.child("users").child(userID!)
            let dic = [AddNoteViewController.selectedUserID! : self.noteField.text] as [String:String]
            ref.child("notes").childByAutoId().setValue(dic)
            print(self.noteField.text)
            let alert = UIAlertController(title: "Notification", message: "Your Note Has Been Saved", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                //self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController?.popViewControllerAnimated(true)  //Changed to Push
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onCancelNote(sender: UIButton) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        
        self.navigationController?.popViewControllerAnimated(true)  //Changed to Push
    }
}