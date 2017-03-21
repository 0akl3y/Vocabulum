//
//  StartBoxViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 06.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

@objc protocol StartBoxDelegate {
    
    func didStartLesson(_ numberOfWords:Int)
    @objc optional func didCancelLesson()

}

class StartBoxViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var numberOfWords: UITextField!
    var delegate:StartBoxDelegate?
    @IBOutlet var startButton: UIButton!
    
    var defaults = UserDefaults.standard
    
    
    //Persist the last setting, as the user might want to keep the preferred value set
    
    var numberSetting: Int? {
        
        get{
            //This check seems to be necessary on older iPads
            if(defaults.object(forKey: "numberOfVocabulary") != nil){
                
                return (defaults.value(forKeyPath: "numberOfVocabulary") as? Int)!
            
            }
            
            else {return nil}
        }
        
        set(numberOfObjects){
            
            defaults.setValue(numberOfObjects, forKey: "numberOfVocabulary")
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.numberOfWords.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.numberOfWords.text = self.numberSetting != nil ? "\(self.numberSetting!)" : "10"

    }
    
    @IBAction func startTraining(_ sender: AnyObject) {
        
        let numberOfWords = Int(self.numberOfWords.text!)
        self.numberSetting = numberOfWords!
        self.delegate?.didStartLesson(numberOfWords!)
        
    }
    
    //MARK:- Text field delegate methoden
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.startButton.isEnabled = textField.text != nil
        textField.resignFirstResponder()
        
    }
}
