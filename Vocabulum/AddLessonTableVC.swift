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
    var currentLesson: Lesson?
    
    @IBOutlet var lessonTitle: UITextField!
    @IBOutlet var lessonDescription: UITextField!

    @IBOutlet var addLessonButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    
    //MARK:- Actions
    
    @IBAction func addLesson(sender: UIBarButtonItem) {
        self.currentLesson = Lesson(title: lessonTitle.text!, lessonDescription: lessonDescription.text)
        self.currentLesson!.lessonToLanguage = self.assignedLanguagePair
        self.performSegueWithIdentifier("addLesson", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! UINavigationController
        let destinationVC = destination.topViewController as! AddVocabularyVC
        destinationVC.relatedLesson = self.currentLesson           
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}
