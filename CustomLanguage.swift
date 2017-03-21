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
    
    //let regionID = "en"
    
    init(langCode:String){
        
        self.langCode = langCode
        
        let locale = Locale.current
        
        //Set the language which name should be displayed (in the users language)
        self.languageName = (locale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: self.langCode)!
        
        let regionalLocale = (Locale(identifier: self.langCode))
        self.translatedLanguageName = (regionalLocale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: self.langCode)!
    }
    
}
