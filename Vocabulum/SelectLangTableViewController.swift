//
//  SelectLangTableViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class SelectLangTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, YandexClientDelegate {
    
    
    weak var currentLanguagePairSetting: LanguagePair?
    @IBOutlet var selectLangTableView: UITableView!

    //Refers to the indx previously selected in the Table View
    var selectedIndx: Int?
    
    var context:NSManagedObjectContext {
        
        return CoreDataStack.sharedObject().managedObjectContext!
    
    }

    var languageFetchRequest = NSFetchRequest(entityName: "Language")
    
    var allLanguages:[Language]?
    
    var yandexClient: YandexClient{
        
        return YandexClient.sharedObject()
    
    }
    
    
    override func viewWillAppear(animated: Bool) {

        
        do {
            
            if let languages = try self.context.executeFetchRequest(self.languageFetchRequest) as? [Language]{
                c
                self.allLanguages = languages
                
            }
            
        }
            
        catch {
            
            print("Failed to fetch languages")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectLangTableView.delegate = self
        selectLangTableView.dataSource = self
        
    }
    

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        return self.allLanguages!.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell", forIndexPath: indexPath)
        
        let currentLanguage = self.allLanguages![indexPath.row]
        let currentLanguageTitle = currentLanguage.languageName
        
        cell.textLabel?.text = currentLanguageTitle

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedLanguage = self.allLanguages![indexPath.row].langCode!
        if(self.selectedIndx == 0){
            
            self.currentLanguagePairSetting?.nativeLanguageID = selectedLanguage
        
        }
        
        else {
            
            self.currentLanguagePairSetting?.trainingLanguageID = selectedLanguage
        
        }
        
        self.navigationController!.popToRootViewControllerAnimated(true)
                
    }
    
    
    //MARK: - YandexClientDelegate methods
    
    func didFetchAllLanguages(){
        
        self.selectLangTableView.reloadData()
    
    }
    
}