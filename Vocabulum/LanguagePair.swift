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
    
    @NSManaged var title: String
    @NSManaged var nativeLanguageID: String
    @NSManaged var trainingLanguageID: String
    @NSManaged var languageToLesson: NSOrderedSet
    
    let localeIdentifier = "en"

    //the full strings for the languages to display in the user interface
    
    var nativeLanguageString: String {
        
        return getStringFromLangID(nativeLanguageID)
    }
    
    var trainingLanguageString: String {
        
        return getStringFromLangID(trainingLanguageID)
    }
    
    func getStringFromLangID(langID:String) -> String{
        
        return "\(NSLocale(localeIdentifier: localeIdentifier).displayNameForKey(NSLocaleIdentifier, value: langID)!) (\(langID))"
    }    
    
    //the language pair identifiers to retrieve words from the yandex API
    
    var languagePairID: String {
        
        return "\(self.nativeLanguageID) - \(self.trainingLanguageID)"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, nativeLanguageID: String, trainingLanguageID: String){
        
        let entityDescription = NSEntityDescription.entityForName("LanguagePair", inManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        super.init(entity: entityDescription!, insertIntoManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.nativeLanguageID = nativeLanguageID
        self.trainingLanguageID = trainingLanguageID
        self.title = title
        
    }

}
