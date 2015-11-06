//
//  StartBoxViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 06.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

@objc protocol StartBoxDelegate {
    
    func didStartLesson(numberOfWords:Int)
    optional func didCancelLesson()

}

class StartBoxViewController: UIViewController {
    
    @IBOutlet var numberOfWords: UITextField!
    var delegate:StartBoxDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startTraining(sender: AnyObject) {
        
        let numberOfWords = Int(self.numberOfWords.text!)
        self.delegate?.didStartLesson(numberOfWords!)
        
    }
}
