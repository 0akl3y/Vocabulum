//
//  Language+CoreData.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 01.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//


extension Language {
    
    func addAvailabTranslation(value:Language){
        
        let items = self.mutableSetValueForKey("availableTranslations")
        items.addObject(value)

    
    }
    
    
    func addAvailableTranslationSet(values:Set<Language>){
        
        let items = self.mutableSetValueForKey("availableTranslations")
        items.unionSet(values)
    
    
    }
        
    
    
    func removeAvailableTranslation(value:Language){
        
        let items = self.mutableSetValueForKey("availableTranslations")
        items.removeObject(value)
    
    }

}
