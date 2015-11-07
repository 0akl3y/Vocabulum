//
//  ErrorHandler.swift
//  
//
//  Created by Johannes Eichler on 07.08.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//
// A very simple error handler to at least give some information

import UIKit


class ErrorHandler: NSObject {
    
    let targetViewController: UIViewController
    init(targetVC:UIViewController){
        
        self.targetViewController = targetVC
    
    }
    
    func displayErrorMessage(error:NSError, handler:((alert:UIAlertAction) -> Void)?){
        let errorMessage = error.userInfo[NSLocalizedDescriptionKey] as! String
        self.displayErrorString(errorMessage, handler:handler)
    }

    
    func displayErrorString(message:String, handler:((alert:UIAlertAction) -> Void)?){
        
        let alertView = UIAlertController(title: "Ooops!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let action = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler:{(action:UIAlertAction)-> Void in action})
        alertView.addAction(action)
        

        self.targetViewController.presentViewController(alertView, animated: true, completion: nil)
    
    }
}
    
