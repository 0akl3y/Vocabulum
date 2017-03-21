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
    @NSManaged var dateAdded: Date
    @NSManaged var lessonToLanguage: LanguagePair
    @NSManaged var lessonToWord: NSSet
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(title: String, lessonDescription: String?){
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Lesson", in: CoreDataStack.sharedObject().managedObjectContext!)
        
        super.init(entity: entityDescription!, insertInto: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.title = title
        self.dateAdded = Date()
        
        if (lessonDescription != nil){
            
            self.lessonDescription = lessonDescription
        
        }
    }
    
    func sectionNameForLesson() -> String {
        
        return self.lessonToLanguage.title
    
    }
        
}
