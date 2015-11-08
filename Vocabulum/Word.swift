//
//  Word.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 16.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import Foundation
import CoreData

enum WordDifficulty:Int{
    
    case known, easy, medium, hard

}

class Word: NSManagedObject {

    @NSManaged var word: String
    @NSManaged var translation: String
    @NSManaged var difficulty: Int64
    @NSManaged var wordToLesson: Lesson
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(word: String, translation: String, difficulty: WordDifficulty){
        
        let entityDescription = NSEntityDescription.entityForName("Word", inManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        super.init(entity: entityDescription!, insertIntoManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
        self.word = word
        self.translation = translation
        self.difficulty = Int64(difficulty.rawValue)
        
    }
        
    func sectionNameForWord() -> String{
        
        return ["Known", "Easy", "Medium", "Hard"][Int(self.difficulty)]
    
    }
}