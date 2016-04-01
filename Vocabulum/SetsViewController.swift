//
//  SetsViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 14.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData


class SetsViewController: UITableViewController, NSFetchedResultsControllerDelegate, BookOverviewCellDelegate {

    @IBOutlet var setTableView: UITableView!
    var managedObjectContext: NSManagedObjectContext? = CoreDataStack.sharedObject().managedObjectContext
    var resultsControllerUpdates = false
    
    var tappedCellIndexPath: NSIndexPath? // keeps track of the cells tapped index path. this is done (instead of the ususal didSelectRow..) because there are mutliple button within each cell that are handled via the BookOberviewCellDelegate methods.
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Lesson", inManagedObjectContext: CoreDataStack.sharedObject().managedObjectContext!)
        fetchRequest.entity = entity
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "lessonToLanguage.title", ascending: true)
        _ = [sortDescriptor]
        
        let sortDescriptorDate = NSSortDescriptor(key: "dateAdded", ascending: true)
        _ = [sortDescriptorDate]
        
        fetchRequest.sortDescriptors = [sortDescriptor,sortDescriptorDate]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedObject().managedObjectContext!, sectionNameKeyPath: "sectionNameForLesson", cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        do {
            try _fetchedResultsController!.performFetch()
        } catch let error1 as NSError {
            error = error1
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            print(error)
            //abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(title: NSLocalizedString("Add Book", comment: ""), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SetsViewController.insertNewObject(_:)))
        
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(animated: Bool) {
        CoreDataStack.sharedObject().saveContext()
    }

    func insertNewObject(sender: AnyObject) {
        self.performSegueWithIdentifier("addSet", sender: sender)
        
    }

    // MARK: - Segues
    @IBAction func openAboutPage(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("showAboutPage", sender: self);
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let targetNavigationVC = segue.destinationViewController as? UINavigationController
        
        switch(segue.identifier!){
            
            case "addLesson":
                
                let targetVC = targetNavigationVC!.topViewController as! AddLessonTableVC
            
                if let senderButton = sender as? AttributedButton{
                    
                    // A new Lesson is added
                    
                    targetVC.assignedLanguagePair = senderButton.languagePair
                    targetVC.navigationItem.title = NSLocalizedString("Add Lesson", comment: "")
                    
                }
            
                else {
                    
                    //An existing Lesson is edited
                    
                    targetVC.currentLesson = (self.fetchedResultsController.objectAtIndexPath(self.tappedCellIndexPath!) as! Lesson)
                    targetVC.navigationItem.title = NSLocalizedString("Edit Lesson", comment: "")
            
                }
            
            case "editVocabulary":
            
                let targetVC = targetNavigationVC!.topViewController as! AddVocabularyVC
                targetVC.relatedLesson = (self.fetchedResultsController.objectAtIndexPath(self.tappedCellIndexPath!) as! Lesson)
            
            case "startLearning":
            
                let targetVC = segue.destinationViewController as! TrainingViewController
                targetVC.lesson = (self.fetchedResultsController.objectAtIndexPath(self.tappedCellIndexPath!) as! Lesson)
            
            
            default:
                break        
        }
        
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! BookOverviewCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //cell.setEditing(tableView.editing, animated: false)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            
            let lessonToDelete = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Lesson
            let wordsToDelete = lessonToDelete.lessonToWord

            context.deleteObject(lessonToDelete)
            _ = wordsToDelete.map {context.deleteObject($0 as! Word)}
                
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0 // a good place for an enum
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let contentView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 40.0) )
        
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        let lesson = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Lesson
        
        let button = AttributedButton(type: UIButtonType.ContactAdd)
        button.setImage(UIImage(named: "add"), forState: UIControlState.Normal)
        button.tintColor = UIColor.whiteColor()
        button.frame.origin.x = tableView.frame.width - (button.frame.width + 10)
        button.frame.origin.y = 10.0

        button.assignLanguagePair(lesson.lessonToLanguage)
        button.addTarget(self, action: #selector(SetsViewController.addLesson(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let removeButton = AttributedButton(frame: button.frame)
        
        removeButton.frame.origin.x = tableView.frame.width - (2 * button.frame.width + 20)
        removeButton.frame.origin.y = 10.0
        removeButton.setImage(UIImage(named: "delete"), forState: UIControlState.Normal)
        
        removeButton.addTarget(self, action: #selector(SetsViewController.confirmDeletion(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        removeButton.assignLanguagePair(lesson.lessonToLanguage)
        
        
        let label = UILabel(frame: CGRectMake(5.0, 2.0, tableView.frame.size.width - (2 * button.frame.width + 20), 40.0))
        label.text = "\(lesson.lessonToLanguage.title): \(lesson.lessonToLanguage.nativeLanguageString!)-\(lesson.lessonToLanguage.trainingLanguageString!)"
        
        contentView.backgroundColor = UIColor.darkGrayColor()
        label.textColor = UIColor.whiteColor()
        
        contentView.addSubview(label)
        contentView.addSubview(button)
        contentView.addSubview(removeButton)
        
        contentView.sizeToFit()

        return contentView
    }
    
    func addLesson(sender:AttributedButton){
        performSegueWithIdentifier("addLesson", sender: sender)
    
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let bookCell = cell as! BookOverviewCell
        
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        bookCell.title!.text = object.valueForKey("title")!.description
        bookCell.cellIndexPath = indexPath
        bookCell.delegate = self
        
    }

    // MARK: - Fetched results controller

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.resultsControllerUpdates = true
        self.tableView.beginUpdates()
        
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)

        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        self.resultsControllerUpdates = false
    }
    
    //MARK:- Book Overview Cell Delegate Methods
    
    func didTapEdit(cellIndexPath: NSIndexPath?) {
        self.tappedCellIndexPath = cellIndexPath
        self.performSegueWithIdentifier("editVocabulary", sender: self)
    }
    
    func didTapStartLearning(cellIndexPath: NSIndexPath?) {
        self.tappedCellIndexPath = cellIndexPath
        self.performSegueWithIdentifier("startLearning", sender: self)
        
    }
    
    func didTapEditLesson(cellIndexPath: NSIndexPath?) {
        self.tappedCellIndexPath = cellIndexPath
        self.performSegueWithIdentifier("addLesson", sender: self)
    }
    
    //MARK:- Remove Set button target
    
    func confirmDeletion(sender:AttributedButton){
        
        let dialogTitle: String = NSLocalizedString("Delete Book", comment: "")
        let dialogMessage: String = NSLocalizedString("Are your sure that you want to delete,", comment:"") + "\(sender.languagePair!.title)"
        
        let dialog: UIAlertController = UIAlertController(title: dialogTitle, message: dialogMessage, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let confirmDelete: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { UIAlertAction in self.removeBook(sender.languagePair!); })
        
        let cancelDelete: UIAlertAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: nil)
        
        dialog.addAction(confirmDelete)
        dialog.addAction(cancelDelete)
        
        presentViewController(dialog, animated: true, completion: nil)
    }
    
    func removeBook(book:LanguagePair){

        self.managedObjectContext?.deleteObject(book)
        CoreDataStack.sharedObject().saveContext()
        
        self.setTableView.reloadData()
        self.setTableView.setNeedsLayout()        
    
    }
    
    //MARK:- Manage size transition of table view
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        //It is necessary to reload the table view, as I can see no other way to rescale the section headers when orientation changesf
        
        //Protect the fetchedResultsController from getting disturbed
        if(!self.resultsControllerUpdates && self.navigationController?.visibleViewController == self) {
            
            self.setTableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
}