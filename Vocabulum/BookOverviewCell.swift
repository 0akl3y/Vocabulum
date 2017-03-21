//
//  BookOverviewCell.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 18.10.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

protocol BookOverviewCellDelegate {
    
    func didTapStartLearning(_ cellIndexPath:IndexPath?)
    func didTapEdit(_ cellIndexPath:IndexPath?)
    func didTapEditLesson(_ cellIndexPath:IndexPath?)

}

class BookOverviewCell: UITableViewCell {
    
    var delegate: BookOverviewCellDelegate?
    var cellIndexPath: IndexPath?
    
    @IBOutlet var editButton: UIButton!
    @IBOutlet var learnButton: UIButton!
    
    @IBOutlet var title: UILabel?
    


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func startLearning(_ sender: UIButton) {
        
        self.delegate?.didTapStartLearning(self.cellIndexPath)

    }

    @IBAction func editBookContent(_ sender: UIButton) {
        
        self.delegate?.didTapEdit(self.cellIndexPath)
    }    
    
    //MARK:- Manage the cells editing accessory type

    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: true)
        
        if(editing){
            
            AnimationKit.fadeOutViews([self.learnButton, self.editButton])
            self.indentationWidth = 20.0
            let editingButton = UIButton(type: UIButtonType.system)
            editingButton.frame.size = CGSize(width: 22.0, height: 22.0)
            
            editingButton.setImage(UIImage(named: "Map Editing"), for: UIControlState())
            
            self.editingAccessoryView = editingButton
            editingButton.addTarget(self, action: #selector(BookOverviewCell.editLesson(_:)), for: UIControlEvents.touchUpInside)
        
        }
        
        else if(!editing) {
        
            AnimationKit.fadeInViews([self.learnButton, self.editButton])
        
        }
        
    }
    func editLesson(_ sender:UIButton){
        
        self.delegate?.didTapEditLesson(self.cellIndexPath)
    
    }
}
