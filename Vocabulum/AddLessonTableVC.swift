//
//  AddLessonTableVC.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 28.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class AddLessonTableVC: UITableViewController {
    
    var assignedLanguagePair: LanguagePair!
    var currentLesson: Lesson? // the selected lesson is passed from set view controller
    
    @IBOutlet var lessonTitle: UITextField!
    @IBOutlet var lessonDescription: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! UINavigationController
        let destinationVC = destination.topViewController as! AddVocabularyVC
        destinationVC.relatedLesson = self.currentLesson           
    }
    
    func saveLesson(){
        
        self.currentLesson = Lesson(title: lessonTitle.text!, lessonDescription: lessonDescription.text)
        self.currentLesson!.lessonToLanguage = self.assignedLanguagePair
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func editVocabulary(sender: AnyObject) {
        
        self.saveLesson()
        let vocabularyVC = self.storyboard?.instantiateViewControllerWithIdentifier("VocabularyVC") as! AddVocabularyVC
        
        vocabularyVC.relatedLesson = self.currentLesson
        self.presentViewController(vocabularyVC, animated: true, completion: nil)
    }
    
    @IBAction func saveLesson(sender: AnyObject) {
        
        self.saveLesson()
        self.dismissViewControllerAnimated(true, completion: {
            
            CoreDataStack.sharedObject().saveContext()
        
        })
        
    }
    
}
