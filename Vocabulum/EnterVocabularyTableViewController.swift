//
//  EnterVocabularyTableViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 02.10.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EnterVocabularyTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var translation: UITextField!
    @IBOutlet var nativeWord: UITextField!
    @IBOutlet var difficultySetting: UISegmentedControl!
    
    @IBOutlet var nativeSpinner: UIActivityIndicatorView!
    @IBOutlet var translationSpinner: UIActivityIndicatorView!

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

        self.addVocButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(EnterVocabularyTableViewController.save(_:)))
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(EnterVocabularyTableViewController.cancel(_:)))
        
        self.addVocButton.isEnabled = false;
        
        self.navigationItem.rightBarButtonItem = addVocButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.translation.delegate = self
        self.nativeWord.delegate = self
        
        nativeWord.addTarget(self, action: #selector(EnterVocabularyTableViewController.updateButtonStatus), for: UIControlEvents.editingChanged)
        
        translation.addTarget(self, action: #selector(EnterVocabularyTableViewController.updateButtonStatus), for: UIControlEvents.editingChanged)
        
        self.errorHandler = ErrorHandler(targetVC: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.yandexButtonNative.isHidden = !self.languageIsSupported
        self.yandexButtonTranslation.isHidden = !self.languageIsSupported
        
        self.nativeWord.placeholder = self.lesson?.lessonToLanguage.nativeLanguageString
        self.translation.placeholder = self.lesson?.lessonToLanguage.trainingLanguageString
        
        if(self.existingWord != nil){
            
            self.translation.text = self.existingWord?.translation
            self.nativeWord.text = self.existingWord?.word
            self.difficultySetting.selectedSegmentIndex = Int((self.existingWord?.difficulty)!)
            self.navigationItem.title = NSLocalizedString("Edit Vocabulary", comment:"")
        }
        else{
            self.navigationItem.title = NSLocalizedString("Add Vocabulary", comment: "")
        }
        self.updateButtonStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.translation.text = nil
        self.nativeWord.text = nil
        self.difficultySetting.selectedSegmentIndex = WordDifficulty.hard.rawValue
        self.existingWord = nil
    }
    
    func updateButtonStatus(){
        
        self.addVocButton.isEnabled = (self.translation.text != nil && self.nativeWord.text != nil) &&  (self.translation.text?.characters.count > 0 && self.nativeWord.text?.characters.count > 0)
        
        self.yandexButtonNative.isEnabled = self.nativeWord.text != nil && self.nativeWord.text?.characters.count > 1
        self.yandexButtonTranslation.isEnabled = self.translation.text != nil && self.translation.text?.characters.count > 1
        

    
    }
    
    //MARK:- Actions
    
    func save(_ sender:UIBarButtonItem){
        
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
        
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func cancel(_ sender:UIBarButtonItem){
        
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.updateButtonStatus()
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButtonStatus()
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func searchYandexNative(_ sender: AnyObject) {
        
        let searchedWord = self.nativeWord.text
        let langPairID = self.lesson?.lessonToLanguage.languagePairID
        
        self.translationSpinner.startAnimating()
        self.translationSpinner.isHidden = false
        
        YandexClient.sharedObject().getVocabularyForWord(searchedWord!, languageCombination: langPairID!) { (translation, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                
                self.translationSpinner.stopAnimating()
                
                if(error != nil){
                    
                    self.errorHandler!.displayErrorMessage(error!, onClose: nil)
                }
                
                self.translation.text = translation
                self.updateButtonStatus()
            })
        }
    }
    
    @IBAction func searchYandexTranslation(_ sender: UIButton) {
        
        let searchedWord = self.translation.text
        let langPairID = self.lesson?.lessonToLanguage.languagePairID
        
        let revertedLangID:String = {()-> String in
            var components: [String] =  langPairID!.components(separatedBy: "-").reversed()
            return "\(components[0])-\(components[1])"
        }()
        
        self.nativeSpinner.startAnimating()
        self.nativeSpinner.isHidden = false
        
        YandexClient.sharedObject().getVocabularyForWord(searchedWord!, languageCombination: revertedLangID) { (translation, error) -> Void in

            self.nativeSpinner.stopAnimating()
            
            if(error != nil){
                self.errorHandler!.displayErrorMessage(error!, onClose: nil)
            }
            
            self.nativeWord.text = translation
            self.updateButtonStatus()
        }
        
    }
    
}
