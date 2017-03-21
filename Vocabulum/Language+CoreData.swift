//
//  Language+CoreData.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 01.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//


extension Language {
    
    func addAvailabTranslation(_ value:Language){
        
        let items = self.mutableSetValue(forKey: "availableTranslations")
        items.add(value)
    
    }
    
    
    func addAvailableTranslationSet(_ values:Set<Language>){
        
        let items = self.mutableSetValue(forKey: "availableTranslations")
        items.union(values)
    
    }
    
    func removeAvailableTranslation(_ value:Language){
        
        let items = self.mutableSetValue(forKey: "availableTranslations")
        items.remove(value)
    
    }

}
