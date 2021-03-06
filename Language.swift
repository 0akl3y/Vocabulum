//
//  Language.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 31.10.15.
//  Copyright © 2015 Eichler. All rights reserved.
//
//This object is for listing the languages fetched from the Yandex API

import Foundation
import CoreData

class Language: NSManagedObject, LanguageObject {

// Insert code here to add functionality to your managed object subclass
    
    @NSManaged var languageName: String
    @NSManaged var langCode: String
    @NSManaged var translatedLanguageName:String

    @NSManaged var availableTranslations: NSSet?
    
    let regionID = "en"
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(langCode:String){
        
        let entityDescription = NSEntityDescription.entityForName("Language", inManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        super.init(entity: entityDescription!, insertIntoManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.langCode = langCode
        
        let locale = NSLocale.currentLocale()
        
        //Set the language which name should be displayed (in the users language)
        self.languageName = locale.displayNameForKey(NSLocaleIdentifier, value: self.langCode)!
        
        let regionalLocale = (NSLocale(localeIdentifier: self.langCode))
        self.translatedLanguageName = regionalLocale.displayNameForKey(NSLocaleIdentifier, value: self.langCode)!
    }
}