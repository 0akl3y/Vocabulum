//
//  EnterVocabularyTableViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 02.10.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class EnterVocabularyTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var translation: UITextField!
    @IBOutlet var nativeWord: UITextField!
    @IBOutlet var difficultySetting: UISegmentedControl!
    
    var displayedWord:Word?
    var lesson:Lesson?
    
    var addVocButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.addVocButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "save:")
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
        
        self.addVocButton.enabled = false;
        
        self.navigationItem.rightBarButtonItem = addVocButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.translation.delegate = self
        self.nativeWord.delegate = self
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func updateButtonStatus(){
        
        self.addVocButton.enabled = (self.translation.text != nil && self.nativeWord.text != nil)
    
    }
    
    func save(sender:UIBarButtonItem){
        
        self.updateButtonStatus()
        
        self.displayedWord = Word(word: self.nativeWord.text, translation: self.translation.text, difficulty: WordDifficulty(rawValue: self.difficultySetting.selectedSegmentIndex)!)
        
        self.displayedWord?.wordToLesson = self.lesson!
        
        CoreDataStack.sharedObject().saveContext()
        
        self.navigationController!.popToRootViewControllerAnimated(true)
    
    }
    
    
    func cancel(sender:UIBarButtonItem){
        
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.updateButtonStatus()
    }

}
