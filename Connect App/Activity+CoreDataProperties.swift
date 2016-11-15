//
//  Activity+CoreDataProperties.swift
//  
//
//  Created by Leqi Long on 8/7/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Activity {

    @NSManaged var category: String?
    @NSManaged var detail: String?
    @NSManaged var icon: String?
    @NSManaged var selectedDate: NSDate?
    @NSManaged var time: NSDate?
    @NSManaged var date: DateShort?

}
