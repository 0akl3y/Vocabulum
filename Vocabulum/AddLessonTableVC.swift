//
//  AddLessonTableVC.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 28.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class AddLessonTableVC: UITableViewController, UITextFieldDelegate {
    
    var assignedLanguagePair: LanguagePair?
    var currentLesson: Lesson? // the selected lesson is passed from set view controller
    
    @IBOutlet var lessonTitle: UITextField!
    @IBOutlet var lessonDescription: UITextField!
    @IBOutlet var editVocButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.lessonTitle.text = self.currentLesson?.title
        self.lessonDescription.text = self.currentLesson?.lessonDescription
        
        if (self.currentLesson != nil){
            //if the lesson does not yet exist, the assignedLanguagePair is passed directly
            
            self.assignedLanguagePair = self.currentLesson?.lessonToLanguage
        }
        
        self.lessonTitle.delegate = self
        self.lessonDescription.delegate = self
        self.updateButtonStatus()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "addVocabulary"){
            
            let destination = segue.destinationViewController as! UINavigationController
            let destinationVC = destination.topViewController as! AddVocabularyVC
            destinationVC.relatedLesson = self.currentLesson
        }
    }
    
    func updateButtonStatus(){
        
        self.editVocButton.enabled = self.lessonTitle.text?.characters.count > 0
        
    }
    
    func saveLesson(){
        
        if(self.currentLesson == nil){
            
            self.currentLesson = Lesson(title: lessonTitle.text!, lessonDescription: lessonDescription.text)
            self.currentLesson!.lessonToLanguage = self.assignedLanguagePair!
            
        }
        
        self.currentLesson?.title = self.lessonTitle.text!
        self.currentLesson?.lessonDescription = self.lessonDescription.text
        self.currentLesson?.lessonToLanguage = self.assignedLanguagePair!
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func editVocabulary(sender: AnyObject) {
        
        self.saveLesson()
        self.performSegueWithIdentifier("addVocabulary", sender: self)
    }
    
    @IBAction func saveLesson(sender: AnyObject) {
        
        self.saveLesson()
        self.dismissViewControllerAnimated(true, completion: {
            
            CoreDataStack.sharedObject().saveContext()
        
        })
    }
    
    //MARK:- Text field delegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.updateButtonStatus()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.updateButtonStatus()
        textField.resignFirstResponder()
    }
    
    // MARK:- TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}