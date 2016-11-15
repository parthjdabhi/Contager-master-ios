//
//  UIViewControllerExtension.swift
//  Calendar
//
//  Created by Leqi Long on 8/6/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController{
    func displayError(message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
