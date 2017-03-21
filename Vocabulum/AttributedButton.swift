
//
//  AttributedButton.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 28.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class AttributedButton: UIButton {
    
    var languagePair:LanguagePair?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func assignLanguagePair(_ languagePair:LanguagePair){
        
        self.languagePair = languagePair
    
    }
    
}
