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
        self.titleField.addTarget(self, action: "updateButtonStatus", forControlEvents: UIControlEvents.EditingChanged)
        self.titleField.addTarget(self, action: "updateButtonStatus", forControlEvents: UIControlEvents.EditingDidEndOnExit)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
 
        self.updateButtonStatus()
        
        if(self.currentLanguagePairSetting == nil){
            
            //Set a sample language pair
            self.currentLanguagePairSetting = LanguagePair(title: "Enter Book Name", nativeLanguageString: nil, trainingLanguageString: nil)        
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
            
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
            
            performSegueWithIdentifier("selectLang", sender: self)
        }        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let targetVC = segue.destinationViewController as! SelectLangTableViewController
        

        
        switch(segue.identifier!){
            
            case "selectLang":
            
                targetVC.selectedIndx = self.selectedIndx!
                targetVC.currentLanguagePairSetting = self.currentLanguagePairSetting
            
            
            default:
            
               return
        }
    }
    
    func updateButtonStatus(){
        
        let textLabelsAreSet = (languageA.textLabel?.text != nil && languageB.textLabel?.text != nil)
        self.saveButton.enabled = (self.titleField != nil && self.titleField.text?.characters.count > 1) && textLabelsAreSet
    
    }
    
// MARK:- Actions    

    @IBAction func close(sender: AnyObject) {
        CoreDataStack.sharedObject().managedObjectContext?.deleteObject(self.currentLanguagePairSetting!)
        self.currentLanguagePairSetting = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        
        self.currentLanguagePairSetting?.title = self.titleField.text!
        // There should be at least one lesson for each language pair section
        
        let lesson = Lesson(title: "Lesson 1", lessonDescription: nil)
        lesson.lessonToLanguage = self.currentLanguagePairSetting!
        
        CoreDataStack.sharedObject().saveContext()

        self.dismissViewControllerAnimated(true, completion: nil)
    }

// MARK:- TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.updateButtonStatus()
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.updateButtonStatus()
        textField.resignFirstResponder()
    }
    
    
}