//
//  TestingExtension.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 24.08.16.
//  Copyright © 2016 Eichler. All rights reserved.
//

import XCTest
@testable import Vocabulum

protocol TestStorageAvailability {


}

extension TestStorageAvailability  {
    
    var yandexClient:YandexClient{
        
        get{
            
            let client = YandexClient.sharedObject()
            client.context = self.coreDataStack.testingManagedObjectContext!
            
            return client
        }
        
    }
    
    
    var coreDataStack:TestingCoreDataStack{
        
        get{
            
            return TestingCoreDataStack()!
        }
        
    }
    
    

}