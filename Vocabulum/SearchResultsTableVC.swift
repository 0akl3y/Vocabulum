//
//  SearchResultsTableVC.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 28.10.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

class SearchResultsTableVC: UITableViewController {

    @IBOutlet var searchTableView: UITableView!
    var searchResult: [Word]?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = self

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResult != nil ? searchResult!.count : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let nib = UINib(nibName: "VocabularyOverviewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! VocabularyOverviewCell
        
        let content = searchResult![indexPath.row]
        
        cell.nativeWord.text = content.word
        cell.translation.text = content.translation        

        return cell
    }
   

}
