//
//  Activity.swift
//  
//
//  Created by Leqi Long on 8/7/16.
//
//

import Foundation
import CoreData


class Activity: NSManagedObject {

    convenience init(detail: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entityForName("Activity", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.detail = detail
        }else{
            fatalError("Unable to find entity name!")
        }
    }


}
