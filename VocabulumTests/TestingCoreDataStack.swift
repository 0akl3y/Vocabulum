//
//  TestingCoreDataStack.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 24.08.16.
//  Copyright © 2016 Eichler. All rights reserved.
//

import CoreData

class TestingCoreDataStack {
    
    
    var testingManagedObjectModel:NSManagedObjectModel?
    var testingStoreCoordinator:NSPersistentStoreCoordinator?
    var testingManagedObjectContext:NSManagedObjectContext?
    
    init?(){
        
        self.testingManagedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])
        self.testingStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.testingManagedObjectModel!)
        
        do{
            try self.testingStoreCoordinator?.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        }
            
        catch{
            
            return nil
            
        }
        
        self.testingManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.testingManagedObjectContext?.persistentStoreCoordinator = self.testingStoreCoordinator
    }
        
    

}
