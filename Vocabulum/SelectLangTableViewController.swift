//
//  SelectLangTableViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class SelectLangTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var currentLanguagePairSetting: LanguagePair?
    @IBOutlet var selectLangTableView: UITableView!

    //Refers to the indx previously selected in the Table View
    var selectedIndx: Int?
    var allLanguageCodes: [String] {
        
        return NSLocale.preferredLanguages() as! [String]
    
    }
    
    var allLanguageStrings: [String] {
        
        let result = self.allLanguageCodes.map({(lang) -> String in
            
            "\(NSLocale(localeIdentifier: lang).displayNameForKey(NSLocaleIdentifier, value: lang)!) (\(lang)) "
            
        })
        
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectLangTableView.delegate = self
        selectLangTableView.dataSource = self
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return self.allLanguageCodes.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("languageCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = self.allLanguageStrings[indexPath.row]

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedLanguage = self.allLanguageCodes[indexPath.row]
        if(self.selectedIndx == 0){
            
            self.currentLanguagePairSetting?.nativeLanguageID = selectedLanguage
        
        }
        
        else {
            
            self.currentLanguagePairSetting?.trainingLanguageID = selectedLanguage
        
        }
        
        self.navigationController!.popToRootViewControllerAnimated(true)
                
    }
    
}