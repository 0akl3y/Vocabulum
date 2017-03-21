//
//  SelectLangTableViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20.09.15.
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


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
    var languageFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Language")
    
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
                
            self.allLanguages = self.allLanguages?.filter {($0.availableTranslations?.contains(where: { (element) -> Bool in
                let lang = element as! Language
                return lang.langCode == setLanguages[0]})
            )!}
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.noLangAvailable.isHidden = true
        self.selectLangTableView.alpha = 1
        
        self.fetchLanguages()
        
    }
    
    
    func fetchLanguages(){
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Language", in: self.context)
        let sortDescriptior = NSSortDescriptor(key: "languageName", ascending: true)
        
        self.languageFetchRequest.entity = entityDescription
        self.languageFetchRequest.sortDescriptors = [sortDescriptior]
        
        //check, if there are already entries in store
        
        
        if try! context.count(for: self.languageFetchRequest) == 0 {
            //No data available yet wait for the YandexClient delegate
            
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        else{
            
            do {
                
                if let languages = try self.context.fetch(self.languageFetchRequest) as? [Language]{
                    self.allLanguages = languages
                    self.filterNonSupportedLangCombinations()
                }
            }
                
            catch {
                
                print("Failed to fetch languages")
            }
        
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(self.allLanguages?.count == 0 && !yandexClient.isFetching){
            
            self.noLangAvailable.isHidden = false
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.languagesDataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath)
        
        let currentLanguage = self.languagesDataSource[indexPath.row]
        let currentLanguageTitle = currentLanguage.languageName
        
        cell.textLabel?.text = currentLanguageTitle        
        cell.detailTextLabel?.text = currentLanguage.translatedLanguageName

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedLanguage = self.languagesDataSource[indexPath.row]
        
        if(self.selectedIndx == 0){
            
            self.currentLanguagePairSetting?.nativeLanguageString = selectedLanguage.languageName
            self.currentLanguagePairSetting?.nativeLanguageCode = selectedLanguage.langCode
            
        }
            
        else {
            
            self.currentLanguagePairSetting?.trainingLanguageString = selectedLanguage.languageName
            self.currentLanguagePairSetting?.trainingLanguageCode = selectedLanguage.langCode
        }
        
        self.navigationController!.popToRootViewController(animated: true)
        
    }
    
    
    //MARK: - YandexClientDelegate methods
    
    func didFetchAllLanguages(){
        
        self.activityIndicator.stopAnimating()
        self.fetchLanguages()
        self.selectLangTableView.reloadData()
    
    }
    
    //MARK: - SearchBarDelegateMethods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchBar.text?.characters.count >= 1){
        
            self.searchFilteredLanguages = self.allLanguages!.filter({ (element:Language) -> Bool in
                element.languageName.contains(searchText)
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.text = ""
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        self.searchMode = false
        self.selectLangTableView.reloadData()
        self.selectLangTableView.setNeedsDisplay()
        
    }
    
    @IBAction func selectOtherLanguage(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "CustomLanguageInput", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "CustomLanguageInput"){
            
            let destinationVC = segue.destination as! CustomLanguageViewController
            destinationVC.currentLanguagePair = self.currentLanguagePairSetting
            destinationVC.selectedIndx = self.selectedIndx
        
        }
    }    
}
