//
//  Date+CoreDataProperties.swift
//  
//
//  Created by Leqi Long on 8/5/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DateShort {

    @NSManaged var date: NSDate?
    @NSManaged var activities: NSSet?

}
