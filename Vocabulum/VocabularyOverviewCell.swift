//
//  VocabularyOverviewCell.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 05.10.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

class VocabularyOverviewCell: UITableViewCell {
    

    @IBOutlet var nativeWord: UILabel!
    @IBOutlet var translation: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
