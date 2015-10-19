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
    func didTapEditLesson(cellIndexPath:NSIndexPath?)

}

class BookOverviewCell: UITableViewCell {
    
    var delegate: BookOverviewCellDelegate?
    var cellIndexPath: NSIndexPath?
    @IBOutlet var editButton: UIButton!
    @IBOutlet var learnButton: UIButton!
    
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
    
    //MARK:- Manage the cells editing accessory type
    
    override func setEditing(editing: Bool, animated: Bool) {
        
        self.indentationWidth = 20.0;
        
        let switchToState:Bool = !self.editing

        self.learnButton.hidden = !self.editing
        self.editButton.hidden = !self.editing
        
        super.setEditing(switchToState, animated: true)
        
        if(self.editing){
            self.indentationWidth = 20.0
            let editingButton = UIButton(type: UIButtonType.InfoDark)
            
            self.editingAccessoryView = editingButton
            //editingButton.titleLabel!.text = "Edit"
            //editingButton.backgroundColor = UIColor.blueColor()
            editingButton.addTarget(self, action: "editLesson:", forControlEvents: UIControlEvents.TouchUpInside)
        
        }
    }
    
    func editLesson(sender:UIButton){
        
        self.delegate?.didTapEditLesson(self.cellIndexPath)
    
    }
}
