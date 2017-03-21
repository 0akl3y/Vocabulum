//
//  CustomLanguageViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 04/11/15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

class CustomLanguageViewController: UITableViewController, UITextFieldDelegate {
    
    var currentLanguagePair:LanguagePair?
    var selectedIndx: Int?
    
    
    @IBOutlet var languageInput: UITextField!
    @IBOutlet var addLanguageButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.languageInput.delegate = self

        // Do any additional setup after loading the view.
    }
    

    @IBAction func addLanguage(_ sender: AnyObject) {
        
        if(self.selectedIndx == 0){
            
            self.currentLanguagePair?.nativeLanguageString = self.languageInput.text!
            self.currentLanguagePair?.nativeLanguageCode = "custom"
            self.navigationController?.popToRootViewController(animated: true)
            
        }
            
        else {
            
            self.currentLanguagePair?.trainingLanguageString = self.languageInput.text!
            self.currentLanguagePair?.trainingLanguageCode = "custom"
            self.navigationController?.popToRootViewController(animated: true)

        }
        
    }
    
    //MARK:- UITextField delegate methoden
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
    }


}
