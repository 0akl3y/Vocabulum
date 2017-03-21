//
//  AnimationKit.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20/10/15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

class AnimationKit: NSObject {
    
    static func fadeInView(_ view:UIView){
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
            view.alpha = 1.0
        }) 
    }
    
    static func fadeOutView(_ view:UIView){
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
            view.alpha = 0
            
        }) 
    
    }
    
    static func fadeInViews(_ views:[UIView]){
        
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                
                for elm in views {
                
                    elm.alpha = 1.0
                    
                }
            }) 
        }
    
    static func fadeOutViews(_ views:[UIView]){
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
            for elm in views {
                
                elm.alpha = 0
                
            }
        }) 
    }
    
    

}
