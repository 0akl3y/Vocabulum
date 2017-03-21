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
    
    func displayErrorMessage(_ error:Error, onClose:(() -> Void)?){
        self.displayErrorString( "\(error)" ) { () -> Void in
            onClose?()
        }
    }

    
    func displayErrorString(_ message:String, onClose:(() -> Void)?){
        
        let alertView = UIAlertController(title: NSLocalizedString("Ooops!", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: UIAlertActionStyle.cancel, handler:{(action:UIAlertAction)-> Void in
            
            alertView.dismiss(animated: true, completion: nil)
            onClose?()
        
        })
        
        alertView.addAction(action)
        
        DispatchQueue.main.async { 
            self.targetViewController.present(alertView, animated: true, completion: nil)
        }

    }
}    
