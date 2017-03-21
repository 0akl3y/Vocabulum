//
//  AddSetViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class AddSetViewController: UITableViewController, UITextFieldDelegate {
    
    var selectedIndx: Int?
    var currentLanguagePairSetting:LanguagePair?
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var languageA: UITableViewCell!
    @IBOutlet var languageB: UITableViewCell!
    
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!

    @IBOutlet var addSetTableView: UITableView!
    
    //keep the value if the user reselects an already set language, as the actual language code is set to nil.
    //when the user pops back from language selection via the back button, the value should be restored

    var previousLanguageCode:String?
    var previousTrainingCode:String?
    
    var previousIsSet:Bool {
        
        return (self.previousLanguageCode != nil) || (self.previousTrainingCode != nil)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleField.delegate = self
        self.titleField.addTarget(self, action: #selector(AddSetViewController.updateButtonStatus), for: UIControlEvents.editingChanged)
        self.titleField.addTarget(self, action: #selector(AddSetViewController.updateButtonStatus), for: UIControlEvents.editingDidEndOnExit)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
 
        self.updateButtonStatus()
        
        if(self.currentLanguagePairSetting == nil){
            
            //Set a sample language pair
            self.currentLanguagePairSetting = LanguagePair(title: NSLocalizedString("Enter Book Name", comment: ""), nativeLanguageString: nil, trainingLanguageString: nil)
        }
        
        else{
            
            if(self.currentLanguagePairSetting?.nativeLanguageCode == nil){
                
                self.currentLanguagePairSetting?.nativeLanguageCode = self.previousLanguageCode
            }
            
            if(self.currentLanguagePairSetting?.trainingLanguageCode == nil){
                
                self.currentLanguagePairSetting?.trainingLanguageCode = self.previousTrainingCode
            }
            

            let nativeLangString:String? = self.currentLanguagePairSetting!.nativeLanguageString
            let trainingLangString:String? = self.currentLanguagePairSetting!.trainingLanguageString

            self.languageA.textLabel?.text = nativeLangString != nil ? nativeLangString : ""
            self.languageB.textLabel?.text = trainingLangString != nil ? trainingLangString : ""
            
            self.updateButtonStatus()
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //exclude the title section at the beginning     
        self.titleField.endEditing(true)
        self.titleField.resignFirstResponder()
        self.updateButtonStatus()
        
        if(indexPath.section == 1){
            //Pass on the index to pass on which language pair should be adjusted
            
            self.selectedIndx = indexPath.row
            
            switch selectedIndx! {
                
                //Handle the case if the user changes an already set language, otherwise the filter for available languages will not work
                
            case 0:
                
                if(self.currentLanguagePairSetting?.nativeLanguageCode != nil){
                    
                    self.previousLanguageCode = self.currentLanguagePairSetting?.nativeLanguageCode!
                    self.currentLanguagePairSetting?.nativeLanguageCode = nil
                
                }
                
            case 1:
                
                if(self.currentLanguagePairSetting?.trainingLanguageCode != nil){
                    
                    self.previousTrainingCode = self.currentLanguagePairSetting?.trainingLanguageCode!
                    self.currentLanguagePairSetting?.trainingLanguageCode = nil
                    
                }
                
            default:
                
                return
            
            }
            
            performSegue(withIdentifier: "selectLang", sender: self)
        }        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let targetVC = segue.destination as! SelectLangTableViewController
        

        
        switch(segue.identifier!){
            
            case "selectLang":
            
                targetVC.selectedIndx = self.selectedIndx!
                targetVC.currentLanguagePairSetting = self.currentLanguagePairSetting
            
            
            default:
            
               return
        }
    }
    
    func updateButtonStatus(){
        
        let textLabelAFilled = languageA.textLabel?.text != nil && languageA.textLabel?.text!.characters.count ?? 0 > 0
        
        let textLabelBFilled = languageB.textLabel?.text != nil && languageB.textLabel?.text!.characters.count ?? 0 > 0
        
        let textLabelsAreSet = textLabelAFilled && textLabelBFilled
        
        self.saveButton.isEnabled = (self.titleField != nil && self.titleField.text?.characters.count ?? 0 > 1) && textLabelsAreSet
    }
    
// MARK:- Actions    

    @IBAction func close(_ sender: AnyObject) {
        CoreDataStack.sharedObject().managedObjectContext?.delete(self.currentLanguagePairSetting!)
        self.currentLanguagePairSetting = nil
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: AnyObject) {
        
        self.currentLanguagePairSetting?.title = self.titleField.text!
        // There should be at least one lesson for each language pair section
        
        let lesson = Lesson(title: NSLocalizedString("Lesson 1", comment: ""), lessonDescription: nil)
        lesson.lessonToLanguage = self.currentLanguagePairSetting!
        
        CoreDataStack.sharedObject().saveContext()

        self.dismiss(animated: true, completion: nil)
    }

// MARK:- TextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.updateButtonStatus()
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.updateButtonStatus()
        textField.resignFirstResponder()
    }
    
    
}
