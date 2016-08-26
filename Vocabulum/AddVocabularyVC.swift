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
    var vocabularyController: NSFetchedResultsController {
        
        if _vocabularyController != nil {
            return _vocabularyController!
        }
        
        let request = NSFetchRequest()
        let sortDescriptorWord = NSSortDescriptor(key: "word", ascending: false)
        let sortDescriptorDifficulty = NSSortDescriptor(key: "difficulty", ascending: false)
        
        let sortDescriptors = [sortDescriptorDifficulty, sortDescriptorWord]
        
        //Show only the words related to the current lesson
        
        if(!isSearchMode){
            
            standardPredicate = NSPredicate(format: ("(wordToLesson.title like %@) AND (wordToLesson.dateAdded == %@)"), self.relatedLesson!.title, self.relatedLesson!.dateAdded )
        }
        
        else{
            
            standardPredicate = NSPredicate(format: "(wordToLesson.title like %@) AND (wordToLesson.dateAdded == %@) AND ((word contains %@) OR (translation contains %@))", self.relatedLesson!.title, self.relatedLesson!.dateAdded, self.searchBar.text!, self.searchBar.text!)
        }
        
        let entity = NSEntityDescription.entityForName("Word", inManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        
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
        
        if(error != nil){
            
            print(error)
            abort()
        }
        
        return _vocabularyController!
    
    }
    
    var _vocabularyController:NSFetchedResultsController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vocabularyTableView.delegate = self
        vocabularyTableView.dataSource = self

        // Do any additional setup after loading the view.
        
        let addVocButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(AddVocabularyVC.insertNewWord(_:)))
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Close", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: #selector(AddVocabularyVC.cancel(_:)))
        
        let editButton = self.editButtonItem()
        
        self.navigationItem.rightBarButtonItem = addVocButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.navigationItem.leftBarButtonItems = [editButton, cancelButton]
        
        self.searchBar = UISearchBar(frame: CGRectMake(0,0,self.vocabularyTableView.frame.size.width,0))
        self.searchBar.sizeToFit()
        
        self.searchBar.showsCancelButton = true
        
        self.vocabularyTableView.tableHeaderView = searchBar
        self.vocabularyTableView.tableHeaderView?.hidden = false
        
        self.searchBar.delegate = self
        self.vocabularyController.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationItem.title = self.relatedLesson?.title
    
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        var error: NSError? = nil
        do {
            try CoreDataStack.sharedObject().managedObjectContext?.save()
        } catch let error1 as NSError {
            error = error1
        }

        if(error != nil){
            
            print(error)
        
        }        
    }
    
    //MARK:- Actions
    
    func insertNewWord(sender:UIBarButtonItem){
        
        performSegueWithIdentifier("enterVocabulary", sender: self)
    
    }
    
    func cancel(sender:UIBarButtonItem){
        
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let targetVC = segue.destinationViewController as! EnterVocabularyTableViewController
        targetVC.lesson = self.relatedLesson
        targetVC.existingWord = self.selectedWord
        self.selectedWord = nil
        
    }
    
    //MARK:- TableView Delegate and Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.vocabularyController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vocabularyController.sections![section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("VocabularyCell") as! VocabularyOverviewCell
        
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.vocabularyController.managedObjectContext
            
            let wordToDelete = self.vocabularyController.objectAtIndexPath(indexPath) as! Word
            
            context.deleteObject(wordToDelete)
            
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let word = self.vocabularyController.objectAtIndexPath(indexPath) as! Word
        self.selectedWord = word
        self.performSegueWithIdentifier("enterVocabulary", sender: self)
    }
    
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let currentObject = self.vocabularyController.objectAtIndexPath(indexPath) as! NSManagedObject
        
        let vocabularyCell = cell as! VocabularyOverviewCell
        
        vocabularyCell.nativeWord!.text = (currentObject.valueForKey("word")!.description)
        vocabularyCell.translation!.text = (currentObject.valueForKey("translation")!.description)
        
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        let label = UILabel(frame: CGRectMake(0.0, 0.0, tableView.frame.size.width, 44.0))
        label.backgroundColor = UIColor.darkGrayColor()
        
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        let word = self.vocabularyController.objectAtIndexPath(indexPath) as! Word

        label.text = word.sectionNameForWord()
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        
        return label
    }
    
    //MARK:- Controller Delegate Methoden
    //test
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.vocabularyTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.vocabularyTableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.vocabularyTableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        self.vocabularyTableView.setNeedsDisplay()
        switch type {
        case .Insert:
            self.vocabularyTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.vocabularyTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)

            
        case .Update:
            self.configureCell(self.vocabularyTableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            self.vocabularyTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.vocabularyTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.vocabularyTableView.endUpdates()
    }
    
    //MARK:- Searchbar Delegate Methoden
    
    
    func cleanAndRefetchResults(){
        
        self._vocabularyController = nil
        
        self.vocabularyTableView.reloadData()
        self.vocabularyTableView.setNeedsDisplay()
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchBar.text?.characters.count >= 1){
            
            self.isSearchMode = true
        }
        
        else{
            
            self.isSearchMode = false

        }
        
        self.cleanAndRefetchResults()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.text = nil
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        self.isSearchMode = false
        self.cleanAndRefetchResults()
 
    }
}