//
//  CustomLanguage.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 04/11/15.
//  Copyright © 2015 Eichler. All rights reserved.
//
//This language object is not persisted, because its only purpose is, to provide information for a View. Custom languages shoudl not be listed in the list of Yandex supported languages

import UIKit
import Foundation

class CustomLanguage: NSObject, LanguageObject {
    
    // Insert code here to add functionality to your managed object subclass
    
    var languageName: String
    var langCode: String
    var translatedLanguageName:String
    
    var availableTranslations: NSSet?
    
    let regionID = "en"
    
    init(langCode:String){
        
        self.langCode = langCode
        
        //Set the users language and region settings. Currently this is always English as there is no localization yet.
        let locale = (NSLocale(localeIdentifier: regionID))
        
        //Set the language which name should be displayed (in the users language)
        self.languageName = locale.displayNameForKey(NSLocaleIdentifier, value: self.langCode)!
        
        let regionalLocale = (NSLocale(localeIdentifier: self.langCode))
        self.translatedLanguageName = regionalLocale.displayNameForKey(NSLocaleIdentifier, value: self.langCode)!
    }
    
}