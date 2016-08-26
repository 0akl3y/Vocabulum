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
        
        super.setEditing(editing, animated: true)
        
        if(editing){
            
            AnimationKit.fadeOutViews([self.learnButton, self.editButton])
            self.indentationWidth = 20.0
            let editingButton = UIButton(type: UIButtonType.System)
            editingButton.frame.size = CGSizeMake(22.0, 22.0)
            
            editingButton.setImage(UIImage(named: "Map Editing"), forState: UIControlState.Normal)
            
            self.editingAccessoryView = editingButton
            editingButton.addTarget(self, action: #selector(BookOverviewCell.editLesson(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        }
        
        else if(!editing) {
        
            AnimationKit.fadeInViews([self.learnButton, self.editButton])
        
        }
        
    }
    func editLesson(sender:UIButton){
        
        self.delegate?.didTapEditLesson(self.cellIndexPath)
    
    }
}
