//
//  BookOverviewCell.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 18.10.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

protocol BookOverviewCellDelegate {
    
    func didTapStartLearning(cellIndexPath:NSIndexPath?)
    func didTapEdit(cellIndexPath:NSIndexPath?)

}

class BookOverviewCell: UITableViewCell {
    
    var delegate: BookOverviewCellDelegate?
    var cellIndexPath: NSIndexPath?
    
    @IBOutlet var title: UILabel?

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func startLearning(sender: UIButton) {
        
        self.delegate?.didTapStartLearning(self.cellIndexPath)

    }

    @IBAction func editBookContent(sender: UIButton) {
        
        self.delegate?.didTapEdit(self.cellIndexPath)
    }
    
}
