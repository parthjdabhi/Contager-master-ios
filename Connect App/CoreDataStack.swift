//
//  CoreDataStack.swift
//  
//
//  Created by Leqi Long on 8/5/16.
//
//

import Foundation
import CoreData

class CoreDataStack{
    //MARK: -Properties
    lazy var model: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "mom")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var coordinator: NSPersistentStoreCoordinator = {
        let coordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let url = self.documentsDirectory.URLByAppendingPathComponent("model.sqlite")
        do{
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }catch{
            print("Unable to add store at \(url)")
        }
        return coordinator
    }()
    
    lazy var databaseURL: NSURL = {
        let url = self.documentsDirectory.URLByAppendingPathComponent("model.sqlite")
        return url
    }()
    
    var documentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var context: NSManagedObjectContext = {
        let coordinator = self.coordinator
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
    
    private init(){}
    
    //MARK: Singleton
    static let sharedInstance = CoreDataStack()
}

extension CoreDataStack{
    func save(){
        context.performBlockAndWait() {
            if self.context.hasChanges{
                do{
                    try self.context.save()
                }catch{
                    fatalError("Error while saving main context: \(error)")
                }
            }
        }
    }
    
    func dropAllData() throws{
        try coordinator.destroyPersistentStoreAtURL(databaseURL, withType:NSSQLiteStoreType , options: nil)
        
        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: databaseURL, options: nil)
        
        
    }
    
}
