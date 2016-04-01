//
//  AnimationKit.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 20/10/15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

class AnimationKit: NSObject {
    
    static func fadeInView(view:UIView){
        
        UIView.animateWithDuration(0.4) { () -> Void in
            
            view.alpha = 1.0
        }
    }
    
    static func fadeOutView(view:UIView){
        
        UIView.animateWithDuration(0.4) { () -> Void in
            
            view.alpha = 0
            
        }
    
    }
    
    static func fadeInViews(views:[UIView]){
        
            UIView.animateWithDuration(0.4) { () -> Void in
                
                for elm in views {
                
                    elm.alpha = 1.0
                    
                }
            }
        }
    
    static func fadeOutViews(views:[UIView]){
        
        UIView.animateWithDuration(0.4) { () -> Void in
            
            for elm in views {
                
                elm.alpha = 0
                
            }
        }
    }
    
    

}
