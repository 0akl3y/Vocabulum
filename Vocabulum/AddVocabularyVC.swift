//
//  AddVocabularyVC.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 01.10.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class AddVocabularyVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate {
    
    
    @IBOutlet var searchBar: UISearchBar!
    var isSearchMode = false
    var standardPredicate:NSPredicate?
    
    var relatedLesson:Lesson?
    @IBOutlet var vocabularyTableView: UITableView!
    var vocabularyController: NSFetchedResultsController {
        
        let request = NSFetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "word", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
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
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.sharedObject().managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        
        var error:NSError? = nil
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if(error != nil){
            
            print(error)
            abort()
        }
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        vocabularyTableView.delegate = self
        vocabularyTableView.dataSource = self

        // Do any additional setup after loading the view.
        
        let addVocButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "insertNewWord:")
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:")
        
        self.navigationItem.rightBarButtonItem = addVocButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        self.searchBar.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        self.vocabularyTableView.reloadData()
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
    }
    
    //MARK:- TableView Delegate and Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vocabularyController.fetchedObjects!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let nib = UINib(nibName: "VocabularyOverviewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "vocCell") 
        let cell = tableView.dequeueReusableCellWithIdentifier("vocCell") as! VocabularyOverviewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let currentObject = self.vocabularyController.objectAtIndexPath(indexPath) as! NSManagedObject
        
        let vocabularyCell = cell as! VocabularyOverviewCell
        
        vocabularyCell.nativeWord!.text = (currentObject.valueForKey("word")!.description)
        vocabularyCell.translation!.text = (currentObject.valueForKey("translation")!.description)
        
        if(indexPath.row % 2 == 0){
            
            cell.contentView.backgroundColor = UIColor(red: 0.697, green: 0.887, blue: 0.955, alpha: 1.000)

        }

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
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {

        self.isSearchMode = true
        self.vocabularyTableView.reloadData()
        self.vocabularyTableView.setNeedsDisplay()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        self.searchBar.text = ""
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        self.isSearchMode = false
        self.vocabularyTableView.reloadData()
        self.vocabularyTableView.setNeedsDisplay()
        
        
    }
 
}