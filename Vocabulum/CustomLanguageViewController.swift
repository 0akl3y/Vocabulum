//
//  CustomLanguageViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 04/11/15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

class CustomLanguageViewController: UITableViewController {
    
    var currentLanguagePair:LanguagePair?
    var selectedIndx: Int?
    
    
    @IBOutlet var languageInput: UITextField!
    @IBOutlet var addLanguageButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func addLanguage(sender: AnyObject) {
        
        if(self.selectedIndx == 0){
            
            self.currentLanguagePair?.nativeLanguageString = self.languageInput.text!
            self.currentLanguagePair?.nativeLanguageCode = "custom"
            self.navigationController?.popToRootViewControllerAnimated(true)
            
            
        }
            
        else {
            
            self.currentLanguagePair?.trainingLanguageString = self.languageInput.text!
            self.currentLanguagePair?.trainingLanguageCode = "custom"
            self.navigationController?.popToRootViewControllerAnimated(true)

        }
        
    }


}
