//
//  Lesson.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 16.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import Foundation
import CoreData

class Lesson: NSManagedObject {
    
    @NSManaged var lessonDescription: String?
    @NSManaged var title: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var lessonToLanguage: LanguagePair
    @NSManaged var lessonToWord: NSSet
    var languagePairName: String {
        
        return self.sectionNameForLesson()
    
    }
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title: String, lessonDescription: String?){
        
        let entityDescription = NSEntityDescription.entityForName("Lesson", inManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        super.init(entity: entityDescription!, insertIntoManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.title = title
        self.dateAdded = NSDate()
        
        if (lessonDescription != nil){
            
            self.lessonDescription = lessonDescription
        
        }
    }
    
    func sectionNameForLesson() -> String {
        
        return self.lessonToLanguage.title
    
    }
        
}
