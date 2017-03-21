//
//  LanguagePair.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 16.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import Foundation
import CoreData

class LanguagePair: NSManagedObject {
    
    //Attributes
    @NSManaged var title: String

    //Relationships
    @NSManaged var languageToLesson: NSOrderedSet

    @NSManaged var nativeLanguageString: String?
    @NSManaged var nativeLanguageCode: String?

    @NSManaged var trainingLanguageString: String?
    @NSManaged var trainingLanguageCode: String?
    
    let localeIdentifier = "en"
    
    //the language pair identifiers to retrieve words from the Yandex API
    
    var languagePairID: String? {
        
        if((self.nativeLanguageCode != nil) && self.trainingLanguageCode != nil){
            
            return "\(self.nativeLanguageCode!)-\(self.trainingLanguageCode!)"
        
        }
        
        //If nil is returned it is a custom language
        return nil
        
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(title: String, nativeLanguageString:String?, trainingLanguageString:String?){
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "LanguagePair", in: CoreDataStack.sharedObject().managedObjectContext!)
        
        super.init(entity: entityDescription!, insertInto: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.nativeLanguageString = nativeLanguageString
        self.trainingLanguageString = trainingLanguageString
        self.title = title
        
    }
}
