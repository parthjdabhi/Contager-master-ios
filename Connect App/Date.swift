//
//  Date.swift
//  
//
//  Created by Leqi Long on 8/5/16.
//
//

import Foundation
import CoreData


class DateShort: NSManagedObject {

    convenience init(date: NSDate, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Date", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.date = date
        }else{
            fatalError("Unable to find entity name!")
        }
    }

}
