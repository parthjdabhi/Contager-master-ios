//
//  PhotoViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 7/9/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class PhotoViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var ref:FIRDatabaseReference!
    var user: FIRUser!
    @IBOutlet var picture: UIImageView!
    var imagePickerController: UIImagePickerController!
    var imgTaken = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser
        
        picture.layer.masksToBounds = false
        picture.layer.cornerRadius = picture.frame.height/2
        picture.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        // 1
        view.endEditing(true)
        
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .ActionSheet)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .Default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .Camera
                                                self.presentViewController(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 4
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .Default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .PhotoLibrary
                                            self.presentViewController(imagePicker,
                                                                       animated: true,
                                                                       completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 5
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        // 6
        presentViewController(imagePickerActionSheet, animated: true,
                              completion: nil)
        
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picture.image = image
        let uploadImage : UIImage = picture.image!
        let base64String = self.imgToBase64(uploadImage)
        SignUpSocialViewController.picture = base64String as String
    }
    
    
    @IBAction func nextButton(sender: AnyObject) {
        
        if imgTaken == false {
            CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Please select the photo")
            return
        }
        
        let uploadImage : UIImage = picture.image!
        let base64String = self.imgToBase64(uploadImage)
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        CommonUtils.sharedUtils.showProgress(self.view, label: "Uploading image...")
        
        ref.child("users").child(userID!).child("image").setValue(base64String) { (error, firebase) in
            CommonUtils.sharedUtils.hideProgress()
            if error == nil {
                let signUpSocialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpSocialViewController") as! SignUpSocialViewController!
                self.navigationController?.pushViewController(signUpSocialViewController, animated: true)
            } else {
                CommonUtils.sharedUtils.showAlert(self, title: "Alert!", message: "Failed uploading profile image")
            }
        }
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    // Activity Indicator methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picture.contentMode = .ScaleAspectFit
            picture.image = self.scaleImage(pickedImage, maxDimension: 300)
            
            picture.image = self.scaleImage(pickedImage, maxDimension: 300)
            let uploadImage : UIImage = picture.image!
            let base64String = self.imgToBase64(uploadImage)
            SignUpSocialViewController.picture = base64String as String
        }
        
        self.imgTaken = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imgToBase64(image: UIImage) -> String {
        let imageData:NSData = UIImagePNGRepresentation(image)!
        let base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(base64String)
        
        return base64String
    }
    
    
    
}
