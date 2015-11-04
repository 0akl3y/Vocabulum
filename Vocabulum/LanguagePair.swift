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
    @NSManaged var nativeLanguage: Language?
    @NSManaged var trainingLanguage: Language?
    
    //A CustomLanguage object should not be persisted
    
    var customNativeLanguageString: String?
    var customTrainingLanguageString: String?
    
    let localeIdentifier = "en"

    //the full strings for the languages to display in the user interface
    
    var nativeLanguageString: String? {
        
        if let language = nativeLanguage?.languageName{
            
            return language
        }
        
        else{

            return customTrainingLanguageString
        }
    }
    
    var trainingLanguageString: String? {
        
        if let language = trainingLanguage?.languageName{
            
            return language
        }
            
        else{
            
                return customNativeLanguageString
        }
    }
    
    //the language pair identifiers to retrieve words from the Yandex API
    
    var languagePairID: String {
        
        return "\(self.nativeLanguage!.langCode) - \(self.trainingLanguage!.langCode)"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, nativeLanguage:Language?, trainingLanguage:Language?){
        
        let entityDescription = NSEntityDescription.entityForName("LanguagePair", inManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        super.init(entity: entityDescription!, insertIntoManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.nativeLanguage = nativeLanguage
        self.trainingLanguage = trainingLanguage
        self.title = title
        
    }
}