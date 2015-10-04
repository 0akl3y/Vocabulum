//
//  AddSetViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class AddSetViewController: UITableViewController, UITableViewDelegate, UITextFieldDelegate {
    
    var selectedIndx: Int?
    var currentLanguagePairSetting:LanguagePair?
    
    @IBOutlet var titleField: UITextField!
    @IBOutlet var languageA: UITableViewCell!
    @IBOutlet var languageB: UITableViewCell!
    
    @IBOutlet var closeButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!

    @IBOutlet var addSetTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleField.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if(self.currentLanguagePairSetting == nil){
            
            self.currentLanguagePairSetting = LanguagePair(title: "DE - EN", nativeLanguageID: "en", trainingLanguageID: "de")
        
        }
        
        self.languageA.textLabel!.text = self.currentLanguagePairSetting!.nativeLanguageString
        self.languageB.textLabel!.text = self.currentLanguagePairSetting!.trainingLanguageString
        //self.titleField.text = self.currentLanguagePairSetting!.title
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //exclude the title section at the beginning
        
        if(indexPath.section > 0){
            
            //Pass on the index to pass on which language pair should be adjusted
            
            self.selectedIndx = indexPath.row
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
            
                targetVC.selectedIndx = nil
        }
    }
    
// MARK:- Actions    

    @IBAction func close(sender: AnyObject) {
        CoreDataStack.sharedObject().managedObjectContext?.deleteObject(self.currentLanguagePairSetting!)
        self.currentLanguagePairSetting = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        
        self.currentLanguagePairSetting?.title = self.titleField.text
        // There should be at least one lesson for each language pair section
        
        var lesson = Lesson(title: "Untitled", lessonDescription: nil)
        lesson.lessonToLanguage = self.currentLanguagePairSetting!
        
        CoreDataStack.sharedObject().saveContext()

        self.dismissViewControllerAnimated(true, completion: nil)
    }

// MARK:- TextField Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }

}