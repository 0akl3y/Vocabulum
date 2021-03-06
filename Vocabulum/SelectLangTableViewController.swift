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
    
    var currentLanguagePairSetting: LanguagePair?

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var noLangAvailable: UILabel!
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
    
    func filterNonSupportedLangCombinations(){
        
        //This is needed to filter the available language combinations, if one language has already been selected
        
        let setLanguages = [currentLanguagePairSetting?.nativeLanguageCode, currentLanguagePairSetting?.trainingLanguageCode].filter { $0 != nil}
        
        if(setLanguages.count == 1){
                
            self.allLanguages = self.allLanguages?.filter {($0.availableTranslations?.contains({ (element) -> Bool in
                let lang = element as! Language
                return lang.langCode == setLanguages[0]})
            )!}
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        self.noLangAvailable.hidden = true
        self.selectLangTableView.alpha = 1
        
        self.fetchLanguages()
        
    }
    
    
    func fetchLanguages(){
        
        let entityDescription = NSEntityDescription.entityForName("Language", inManagedObjectContext: self.context)
        let sortDescriptior = NSSortDescriptor(key: "languageName", ascending: true)
        
        self.languageFetchRequest.entity = entityDescription
        self.languageFetchRequest.sortDescriptors = [sortDescriptior]
        
        //check, if there are already entries in store
        
        
        if(self.context.countForFetchRequest(self.languageFetchRequest, error: nil) == 0){
            //No data available yet wait for the YandexClient delegate
            
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
        }
        
        else{
            
            do {
                
                if let languages = try self.context.executeFetchRequest(self.languageFetchRequest) as? [Language]{
                    self.allLanguages = languages
                    self.filterNonSupportedLangCombinations()
                }
            }
                
            catch {
                
                print("Failed to fetch languages")
            }
        
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if(self.allLanguages?.count == 0 && !yandexClient.isFetching){
            
            self.noLangAvailable.hidden = false
            AnimationKit.fadeInView(self.noLangAvailable)
            AnimationKit.fadeOutView(self.selectLangTableView)
            
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
        
        self.activityIndicator.stopAnimating()
        self.fetchLanguages()
        self.selectLangTableView.reloadData()
    
    }
    
    //MARK: - SearchBarDelegateMethods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchBar.text?.characters.count >= 1){
        
            self.searchFilteredLanguages = self.allLanguages!.filter({ (element:Language) -> Bool in
                element.languageName.containsString(searchText)
            })

            self.searchMode = true
            self.selectLangTableView.reloadData()
            self.selectLangTableView.setNeedsDisplay()
        }
        
        else {
            self.searchMode = false
            self.selectLangTableView.reloadData()
            self.selectLangTableView.setNeedsDisplay()
        }
        
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