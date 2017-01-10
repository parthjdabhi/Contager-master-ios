//
//  Activity.swift
//  
//
//  Created by Leqi Long on 8/7/16.
//
//

import Foundation
import CoreData



class Activity: NSObject {

    var key: String?
    var category: String?
    var detail: String?
    var icon: String?
    var selectedDate: NSDate?
    var time: NSDate?
    var date: NSDate?
    
    override init() {
        
    }
    
    init(key: String)
    {
        self.key = key
    }
}
