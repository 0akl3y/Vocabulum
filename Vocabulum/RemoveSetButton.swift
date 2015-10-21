//
//  RemoveSetButton.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 21/10/15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

protocol RemoveSetButtonDelegate {
    
    func didTapRemoveSet()

}

class RemoveSetButton: UIButton {
    
    var referencedSet: LanguagePair?
    var delegate: RemoveSetButtonDelegate?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.targetForAction("handleTap:", withSender: self)
    
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleTap(sender:UIButton){
    
    }
    
    
    

    

}
