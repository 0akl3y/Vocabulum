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
    
    var referencedSet: LanguagePair!
    var delegate: RemoveSetButtonDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.targetForAction("handleTap:", withSender: self)
    }

    
    func handleTap(sender:UIButton){
                        
        CoreDataStack.sharedObject().delete(self.referencedSet)
        CoreDataStack.sharedObject().saveContext()
        
        delegate?.didTapRemoveSet()
    
    }

    

}
