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
    var existingWord:Word?
    
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
        
        if(self.existingWord != nil){
            
            self.translation.text = self.existingWord?.translation
            self.nativeWord.text = self.existingWord?.word
            self.difficultySetting.selectedSegmentIndex = Int((self.existingWord?.difficulty)!)
        
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.translation.text = nil
        self.nativeWord.text = nil
        self.difficultySetting.selectedSegmentIndex = WordDifficulty.hard.rawValue
    }
    
    func updateButtonStatus(){
        
        self.addVocButton.enabled = (self.translation.text != nil && self.nativeWord.text != nil)
    
    }
    
    func save(sender:UIBarButtonItem){
        
        self.updateButtonStatus()
        
        //check if no existing word has been passed on to the vc
        
        if(self.existingWord != nil){
            
            self.displayedWord = Word(word: self.nativeWord.text!, translation: self.translation.text!, difficulty:WordDifficulty(rawValue: self.difficultySetting.selectedSegmentIndex)!)
        }
        
        else{
            
            self.existingWord?.translation = self.translation.text!
            self.existingWord?.word = self.nativeWord.text!
            self.existingWord?.difficulty = Int64(self.difficultySetting.selectedSegmentIndex)
        }
        
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
