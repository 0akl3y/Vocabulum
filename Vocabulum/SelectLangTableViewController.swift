//
//  SelectLangTableViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class SelectLangTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, YandexClientDelegate, UISearchBarDelegate {
    
    weak var currentLanguagePairSetting: LanguagePair?

    @IBOutlet var selectLangTableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    //Refers to the indx previously selected in the Table View
    var selectedIndx: Int?
    
    var context:NSManagedObjectContext {
        
        return CoreDataStack.sharedObject().managedObjectContext!
    
    }
    
    var searchMode: Bool = false
    var languageFetchRequest = NSFetchRequest(entityName: "Language")
    
    var allLanguages:[Language]?
    var searchFilteredLanguages: [Language]?

    var languagesDataSource:[Language] {
        
        return self.searchMode == true ? self.searchFilteredLanguages! : self.allLanguages!
    
    }
    
    var yandexClient: YandexClient{
        
        return YandexClient.sharedObject()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let entityDescription = NSEntityDescription.entityForName("Language", inManagedObjectContext: self.context)
        let sortDescriptior = NSSortDescriptor(key: "languageName", ascending: true)
        
        self.languageFetchRequest.entity = entityDescription
        self.languageFetchRequest.sortDescriptors = [sortDescriptior]

        
        do {
            
            if let languages = try self.context.executeFetchRequest(self.languageFetchRequest) as? [Language]{
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
        self.searchBar.delegate = self
        
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.languagesDataSource.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell", forIndexPath: indexPath)
        
        let currentLanguage = self.languagesDataSource[indexPath.row]
        let currentLanguageTitle = currentLanguage.languageName
        
        cell.textLabel?.text = currentLanguageTitle
        cell.detailTextLabel?.text = currentLanguage.translatedLanguageName

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedLanguage = self.languagesDataSource[indexPath.row]
        if(self.selectedIndx == 0){
            
            self.currentLanguagePairSetting?.nativeLanguageString = selectedLanguage.languageName
            self.currentLanguagePairSetting?.nativeLanguageCode = selectedLanguage.langCode
            
        }
        
        else {
            
            self.currentLanguagePairSetting?.trainingLanguageString = selectedLanguage.languageName
            self.currentLanguagePairSetting?.trainingLanguageCode = selectedLanguage.langCode
        }
        
        self.navigationController!.popToRootViewControllerAnimated(true)
                
    }
    
    
    //MARK: - YandexClientDelegate methods
    
    func didFetchAllLanguages(){
        
        self.selectLangTableView.reloadData()
    
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchFilteredLanguages = self.allLanguages!.filter({ (element:Language) -> Bool in
            element.languageName.containsString(searchText)
        })
        
        
        self.searchMode = true
        self.selectLangTableView.reloadData()
        self.selectLangTableView.setNeedsDisplay()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.text = ""
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        self.searchMode = false
        self.selectLangTableView.reloadData()
        self.selectLangTableView.setNeedsDisplay()
        
    }
    
    @IBAction func selectOtherLanguage(sender: AnyObject) {
        
        self.performSegueWithIdentifier("CustomLanguageInput", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "CustomLanguageInput"){
            
            let destinationVC = segue.destinationViewController as! CustomLanguageViewController
            destinationVC.currentLanguagePair = self.currentLanguagePairSetting
            destinationVC.selectedIndx = self.selectedIndx
        
        }
    }    
}