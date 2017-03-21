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
    
    var tappedCellIndexPath: IndexPath? // keeps track of the cells tapped index path. this is done (instead of the ususal didSelectRow..) because there are mutliple button within each cell that are handled via the BookOberviewCellDelegate methods.
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: "Lesson", in: CoreDataStack.sharedObject().managedObjectContext!)
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
            //abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let addButton = UIBarButtonItem(title: NSLocalizedString("Add Book", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(SetsViewController.insertNewObject(_:)))
        
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoreDataStack.sharedObject().saveContext()
    }

    func insertNewObject(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "addSet", sender: sender)
        
    }

    // MARK: - Segues
    @IBAction func openAboutPage(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "showAboutPage", sender: self);
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let targetNavigationVC = segue.destination as? UINavigationController
        
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
                    
                    targetVC.currentLesson = (self.fetchedResultsController.object(at: self.tappedCellIndexPath!) as! Lesson)
                    targetVC.navigationItem.title = NSLocalizedString("Edit Lesson", comment: "")
            
                }
            
            case "editVocabulary":
            
                let targetVC = targetNavigationVC!.topViewController as! AddVocabularyVC
                targetVC.relatedLesson = (self.fetchedResultsController.object(at: self.tappedCellIndexPath!) as! Lesson)
            
            case "startLearning":
            
                let targetVC = segue.destination as! TrainingViewController
                targetVC.lesson = (self.fetchedResultsController.object(at: self.tappedCellIndexPath!) as! Lesson)
            
            
            default:
                break        
        }
        
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BookOverviewCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.setEditing(tableView.editing, animated: false)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            
            let lessonToDelete = self.fetchedResultsController.object(at: indexPath) as! Lesson
            let wordsToDelete = lessonToDelete.lessonToWord

            context.delete(lessonToDelete)
            _ = wordsToDelete.map {context.delete($0 as! Word)}
                
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0 // a good place for an enum
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40.0) )
        
        let indexPath = IndexPath(row: 0, section: section)
        let lesson = self.fetchedResultsController.object(at: indexPath) as! Lesson
        
        let button = AttributedButton(type: UIButtonType.contactAdd)
        button.setImage(UIImage(named: "add"), for: UIControlState())
        button.tintColor = UIColor.white
        button.frame.origin.x = tableView.frame.width - (button.frame.width + 10)
        button.frame.origin.y = 10.0

        button.assignLanguagePair(lesson.lessonToLanguage)
        button.addTarget(self, action: #selector(SetsViewController.addLesson(_:)), for: UIControlEvents.touchUpInside)
        
        let removeButton = AttributedButton(frame: button.frame)
        
        removeButton.frame.origin.x = tableView.frame.width - (2 * button.frame.width + 20)
        removeButton.frame.origin.y = 10.0
        removeButton.setImage(UIImage(named: "delete"), for: UIControlState())
        
        removeButton.addTarget(self, action: #selector(SetsViewController.confirmDeletion(_:)), for: UIControlEvents.touchUpInside)
        removeButton.assignLanguagePair(lesson.lessonToLanguage)
        
        
        let label = UILabel(frame: CGRect(x: 5.0, y: 2.0, width: tableView.frame.size.width - (2 * button.frame.width + 20), height: 40.0))
        label.text = "\(lesson.lessonToLanguage.title): \(lesson.lessonToLanguage.nativeLanguageString!)-\(lesson.lessonToLanguage.trainingLanguageString!)"
        
        contentView.backgroundColor = UIColor.darkGray
        label.textColor = UIColor.white
        
        contentView.addSubview(label)
        contentView.addSubview(button)
        contentView.addSubview(removeButton)
        
        contentView.sizeToFit()

        return contentView
    }
    
    func addLesson(_ sender:AttributedButton){
        performSegue(withIdentifier: "addLesson", sender: sender)
    
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        
        let bookCell = cell as! BookOverviewCell
        
        let object = self.fetchedResultsController.object(at: indexPath) as! NSManagedObject
        bookCell.title!.text = object.value(forKey: "title") as! String?
        bookCell.cellIndexPath = indexPath
        bookCell.delegate = self
        
    }

    // MARK: - Fetched results controller

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.resultsControllerUpdates = true
        self.tableView.beginUpdates()
        
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)

        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        self.resultsControllerUpdates = false
    }
    
    //MARK:- Book Overview Cell Delegate Methods
    
    func didTapEdit(_ cellIndexPath: IndexPath?) {
        self.tappedCellIndexPath = cellIndexPath
        self.performSegue(withIdentifier: "editVocabulary", sender: self)
    }
    
    func didTapStartLearning(_ cellIndexPath: IndexPath?) {
        self.tappedCellIndexPath = cellIndexPath
        self.performSegue(withIdentifier: "startLearning", sender: self)
        
    }
    
    func didTapEditLesson(_ cellIndexPath: IndexPath?) {
        self.tappedCellIndexPath = cellIndexPath
        self.performSegue(withIdentifier: "addLesson", sender: self)
    }
    
    //MARK:- Remove Set button target
    
    func confirmDeletion(_ sender:AttributedButton){
        
        let dialogTitle: String = NSLocalizedString("Delete Book", comment: "")
        let dialogMessage: String = NSLocalizedString("Are your sure that you want to delete,", comment:"") + "\(sender.languagePair!.title)"
        
        let dialog: UIAlertController = UIAlertController(title: dialogTitle, message: dialogMessage, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let confirmDelete: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.destructive, handler: { UIAlertAction in self.removeBook(sender.languagePair!); })
        
        let cancelDelete: UIAlertAction = UIAlertAction(title: NSLocalizedString("NO", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        
        dialog.addAction(confirmDelete)
        dialog.addAction(cancelDelete)
        
        present(dialog, animated: true, completion: nil)
    }
    
    func removeBook(_ book:LanguagePair){

        self.managedObjectContext?.delete(book)
        CoreDataStack.sharedObject().saveContext()
        
        self.setTableView.reloadData()
        self.setTableView.setNeedsLayout()        
    
    }
    
    //MARK:- Manage size transition of table view
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //It is necessary to reload the table view, as I can see no other way to rescale the section headers when orientation changesf
        
        //Protect the fetchedResultsController from getting disturbed
        if(!self.resultsControllerUpdates && self.navigationController?.visibleViewController == self) {
            
            self.setTableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
}
