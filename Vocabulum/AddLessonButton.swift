
//
//  AddLessonButton.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 28.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class AddLessonButton: UIButton {
    
    var languagePair:LanguagePair?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func assignLanguagePair(languagePair:LanguagePair){
        
        self.languagePair = languagePair
    
    }
    
}
