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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(langCode:String){
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Language", in: CoreDataStack.sharedObject().managedObjectContext!)
        super.init(entity: entityDescription!, insertInto: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.langCode = langCode
        
        let locale = Locale.current
        
        //Set the language which name should be displayed (in the users language)
        self.languageName = (locale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: self.langCode) ?? ""
        
        
        let regionalLocale = (Locale(identifier: self.langCode))
        self.translatedLanguageName = (regionalLocale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: self.langCode) ?? ""
    }
}
