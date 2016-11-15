//
//  QRCreatorViewController.swift
//  Connect App
//
//  Created by Dustin Allen on 6/21/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

var qrcodeImage: CIImage!
var ref:FIRDatabaseReference!

class QRCreatorViewController: UIViewController {
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var imgQRCode: UIImageView!
    
    @IBOutlet var btnAction: UIButton!
    
    @IBOutlet var slider: UISlider!
    
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("QRBack", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(animated: Bool) {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).child("facebookData").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // Get user value
            if let image_url = snapshot.value!["email"]  {
                print(image_url)
                let image_url_string = image_url as! String!
                let url = NSURL(string: "\(image_url_string)")
                self.imgQRCode.sd_setImageWithURL(url)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func performButtonAction(sender: AnyObject) {
        
        if qrcodeImage == nil {
            if textField.text == "" {
                return
            }
            
            let data = textField.text!.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            
            qrcodeImage = filter!.outputImage
            
            textField.resignFirstResponder()
            
            btnAction.setTitle("Clear", forState: UIControlState.Normal)
            
            displayQRCodeImage()
        }
        else {
            imgQRCode.image = nil
            qrcodeImage = nil
            btnAction.setTitle("Generate", forState: UIControlState.Normal)
        }
        
        textField.enabled = !textField.enabled
        slider.hidden = !slider.hidden
        
    }
    
    @IBAction func changeImageViewScale(sender: AnyObject) {
        
        imgQRCode.transform = CGAffineTransformMakeScale(CGFloat(slider.value), CGFloat(slider.value))
        
    }
    
    func displayQRCodeImage() {
        let scaleX = imgQRCode.frame.size.width / qrcodeImage.extent.size.width
        let scaleY = imgQRCode.frame.size.height / qrcodeImage.extent.size.height
        
        let transformedImage = qrcodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        imgQRCode.image = UIImage(CIImage: transformedImage)
    }

}
