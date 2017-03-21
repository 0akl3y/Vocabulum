//
//  AddVocabularyVC.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 01.10.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class AddVocabularyVC: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    var searchBar: UISearchBar!
    var isSearchMode = false
    var standardPredicate:NSPredicate?
    
    var selectedWord:Word?
    
    var relatedLesson:Lesson?
    @IBOutlet var vocabularyTableView: UITableView!
    var vocabularyController: NSFetchedResultsController<NSFetchRequestResult> {
        
        if _vocabularyController != nil {
            return _vocabularyController!
        }
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        let sortDescriptorWord = NSSortDescriptor(key: "word", ascending: false)
        let sortDescriptorDifficulty = NSSortDescriptor(key: "difficulty", ascending: false)
        
        let sortDescriptors = [sortDescriptorDifficulty, sortDescriptorWord]
        
        //Show only the words related to the current lesson
        
        if(!isSearchMode){
            standardPredicate = NSPredicate(format:"(wordToLesson.title like %@) AND (wordToLesson.dateAdded == %@)", self.relatedLesson!.title, self.relatedLesson!.dateAdded as CVarArg)
        }
        
        else{
            standardPredicate = NSPredicate(format: "(wordToLesson.title like %@) AND (wordToLesson.dateAdded == %@) AND ((word CONTAINS[c] %@) OR (translation CONTAINS[c] %@))", self.relatedLesson!.title, self.relatedLesson!.dateAdded as CVarArg, self.searchBar.text!, self.searchBar.text! )
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "Word", in: CoreDataStack.sharedObject().managedObjectContext!)
        
        request.sortDescriptors = sortDescriptors
        request.entity = entity
        request.predicate = standardPredicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.sharedObject().managedObjectContext!, sectionNameKeyPath: "sectionNameForWord", cacheName: nil)
        
        fetchedResultsController.delegate = self
        _vocabularyController = fetchedResultsController
        
        
        var error:NSError? = nil
        do {
            try _vocabularyController!.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        return _vocabularyController!
    }
    
    var _vocabularyController:NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vocabularyTableView.delegate = self
        vocabularyTableView.dataSource = self

        // Do any additional setup after loading the view.
        
        let addVocButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(AddVocabularyVC.insertNewWord(_:)))
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(AddVocabularyVC.cancel(_:)))
        
        let editButton = self.editButtonItem
        
        self.navigationItem.rightBarButtonItem = addVocButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.navigationItem.leftBarButtonItems = [editButton, cancelButton]
        
        self.searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: self.vocabularyTableView.frame.size.width,height: 0))
        self.searchBar.sizeToFit()
        
        self.searchBar.showsCancelButton = true
        
        self.vocabularyTableView.tableHeaderView = searchBar
        self.vocabularyTableView.tableHeaderView?.isHidden = false
        
        self.searchBar.delegate = self
        self.vocabularyController.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = self.relatedLesson?.title
    
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var error: NSError? = nil
        do {
            try CoreDataStack.sharedObject().managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }
        
    }
    
    //MARK:- Actions
    
    func insertNewWord(_ sender:UIBarButtonItem){
        
        performSegue(withIdentifier: "enterVocabulary", sender: self)
    
    }
    
    func cancel(_ sender:UIBarButtonItem){
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let targetVC = segue.destination as! EnterVocabularyTableViewController
        targetVC.lesson = self.relatedLesson
        targetVC.existingWord = self.selectedWord
        self.selectedWord = nil
        
    }
    
    //MARK:- TableView Delegate and Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.vocabularyController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vocabularyController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "VocabularyCell") as! VocabularyOverviewCell
        
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.vocabularyController.managedObjectContext
            
            let wordToDelete = self.vocabularyController.object(at: indexPath) as! Word
            
            context.delete(wordToDelete)
            
            var error: NSError? = nil
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                
                print(error)
                abort()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = self.vocabularyController.object(at: indexPath) as! Word
        self.selectedWord = word
        self.performSegue(withIdentifier: "enterVocabulary", sender: self)
    }
    
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        
        let currentObject = self.vocabularyController.object(at: indexPath) as! Word
        
        let vocabularyCell = cell as! VocabularyOverviewCell
        
        vocabularyCell.nativeWord!.text = currentObject.value(forKey: "word") as? String ?? ""
        vocabularyCell.translation!.text = currentObject.value(forKey: "translation") as? String ?? ""
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: 44.0))
        label.backgroundColor = UIColor.darkGray
        
        let indexPath = IndexPath(row: 0, section: section)
        let word = self.vocabularyController.object(at: indexPath) as! Word

        label.text = word.sectionNameForWord()
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        
        return label
    }
    
    //MARK:- Controller Delegate Methoden
    //test
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.vocabularyTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.vocabularyTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.vocabularyTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        self.vocabularyTableView.setNeedsDisplay()
        switch type {
        case .insert:
            self.vocabularyTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.vocabularyTableView.deleteRows(at: [indexPath!], with: .fade)

            
        case .update:
            self.configureCell(self.vocabularyTableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            self.vocabularyTableView.deleteRows(at: [indexPath!], with: .fade)
            self.vocabularyTableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.vocabularyTableView.endUpdates()
    }
    
    //MARK:- Searchbar Delegate Methoden
    
    
    func cleanAndRefetchResults(){
        
        self._vocabularyController = nil
        
        self.vocabularyTableView.reloadData()
        self.vocabularyTableView.setNeedsDisplay()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchBar.text?.characters.count ?? 0 >= 1){
            
            self.isSearchMode = true
        }
        
        else{
            
            self.isSearchMode = false

        }
        
        self.cleanAndRefetchResults()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.text = nil
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        self.isSearchMode = false
        self.cleanAndRefetchResults()
 
    }
}
