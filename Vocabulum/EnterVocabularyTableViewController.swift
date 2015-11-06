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
    

    @IBOutlet var yandexButtonNative: UIButton!
    @IBOutlet var yandexButtonTranslation: UIButton!
    
    
    var displayedWord:Word?
    var existingWord:Word?
    
    var lesson:Lesson?
    
    var addVocButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var errorHandler:ErrorHandler?
    
    var languageIsSupported:Bool {
        
        return (self.lesson?.lessonToLanguage.nativeLanguageCode != "custom") && (self.lesson?.lessonToLanguage.trainingLanguageCode != "custom")
    
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.addVocButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "save:")
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
        
        self.addVocButton.enabled = false;
        
        self.navigationItem.rightBarButtonItem = addVocButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.translation.delegate = self
        self.nativeWord.delegate = self
        self.errorHandler = ErrorHandler(targetVC: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.yandexButtonNative.hidden = !self.languageIsSupported
        
        if(self.existingWord != nil){
            
            self.translation.text = self.existingWord?.translation
            self.nativeWord.text = self.existingWord?.word
            self.difficultySetting.selectedSegmentIndex = Int((self.existingWord?.difficulty)!)
            self.navigationItem.title = "Edit Vocabulary"
        }
        else{
            self.navigationItem.title = "Add Vocabulary"
        }
        self.updateButtonStatus()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.translation.text = nil
        self.nativeWord.text = nil
        self.difficultySetting.selectedSegmentIndex = WordDifficulty.hard.rawValue
        self.existingWord = nil
    }
    
    func updateButtonStatus(){
        
        self.addVocButton.enabled = (self.translation.text != nil && self.nativeWord.text != nil)
        
        self.yandexButtonNative.enabled = self.nativeWord.text != nil && self.nativeWord.text?.characters.count > 1
    
    }
    
    //MARK:- Actions
    
    func save(sender:UIBarButtonItem){
        
        self.updateButtonStatus()
        
        //check if no existing word has been passed on to the vc
        
        if(self.existingWord == nil){
            
            self.displayedWord = Word(word: self.nativeWord.text!, translation: self.translation.text!, difficulty:WordDifficulty(rawValue: self.difficultySetting.selectedSegmentIndex)!)
            
            self.displayedWord?.wordToLesson = self.lesson!
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
    
    @IBAction func searchYandexNative(sender: AnyObject) {
        
        let searchedWord = self.nativeWord.text
        let langPairID = self.lesson?.lessonToLanguage.languagePairID
        
        YandexClient.sharedObject().getVocabularyForWord(searchedWord!, languageCombination: langPairID!) { (translation, error) -> Void in
            
            if(error != nil){
                self.errorHandler!.displayErrorMessage(error!)
            }
            
            self.translation.text = translation

        }
    }
    
    @IBAction func searchYandexTranslation(sender: UIButton) {
        
        let searchedWord = self.translation.text
        let langPairID = self.lesson?.lessonToLanguage.languagePairID
        
        let revertedLangID:String = {()-> String in
            var components: [String] =  langPairID!.componentsSeparatedByString("-").reverse()
            return "\(components[1])-\(components[0])"
        }()
        
        
        YandexClient.sharedObject().getVocabularyForWord(searchedWord!, languageCombination: revertedLangID) { (translation, error) -> Void in
            if(error != nil){
                self.errorHandler!.displayErrorMessage(error!)
            }
            
            self.nativeWord.text = translation
        }
        
    }
    
}
