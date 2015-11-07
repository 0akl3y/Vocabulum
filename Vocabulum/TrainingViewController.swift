//
//  TrainingViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 06.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class TrainingViewController: UIViewController, StartBoxDelegate {

    @IBOutlet var resultIconContainer: UIImageView!
    @IBOutlet var word: UILabel!
    @IBOutlet var userInput: UITextField!
    @IBOutlet var enterButton: UIButton!
    
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var dialogContainer: UIView!
    
    var errorHandler:ErrorHandler?
    
    var wordsForTraining:[Word]?
    var answer:String?
    var question:String?
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var lesson:Lesson?
    var startDialog:StartBoxViewController?
    var sessionOverDialog:TrainingOverViewController?
    
    var correctAnswers:Int = 0
    
    let correctImage = UIImage(named: "correct")
    let wrongImage = UIImage(named: "wrong")
    
    
    //Persist the last setting, as the user might want to keep the preferred value set
    
    var numberSetting: Int {
        
        get{
            return (defaults.valueForKeyPath("numberOfVocabulary") as? Int)!
        }
        
        set(numberOfObjects){
            
            defaults.setValue(numberOfObjects, forKey: "numberOfVocabulary")
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDialog = (self.storyboard?.instantiateViewControllerWithIdentifier("startBox") as! StartBoxViewController)
        self.sessionOverDialog = (self.storyboard?.instantiateViewControllerWithIdentifier("endBox") as! TrainingOverViewController)
        
        self.errorHandler = ErrorHandler(targetVC: self)
        
        self.startDialog!.delegate = self
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.correctAnswers = 0
        
        self.resultIconContainer.alpha = 0
        if(self.lesson?.lessonToWord.count == 0){
            
            self.errorHandler?.displayErrorString("This lesson has no vocabulary yet", handler: {(alertAction:UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion:nil)})
        }

        else{
            
            self.showChild(self.startDialog!)
        }
    }
    
    //MARK:- Fetch Vocabulary
    
    func getVocabulary(numberOfWords: Int){
        
        //Gets the words for the training, if numberOfWords > available entries. the words might be asked mutliple times
        
        self.numberSetting = numberOfWords
        
        let sortDescriptor = NSSortDescriptor(key: "difficulty", ascending: true)
        let words = self.lesson?.lessonToWord.sortedArrayUsingDescriptors([sortDescriptor])
        
        for number in 0...(numberOfWords - 1) {
            
            let currentWord = words![(number % words!.count)]
            self.wordsForTraining!.append(currentWord as! Word)
            
        }
    }
    
    func getWords(){
        
        //Gets question & answer from the array of words
        
        if let word = self.wordsForTraining?.popLast(){
            
            let coinflip = Int(arc4random() % 2)
            
            var wordPair = [word.translation, word.word]
            self.question = wordPair[coinflip]
            wordPair.removeAtIndex(coinflip)
            self.answer = wordPair[0]
            
            self.word.text = self.question
        }
        
        else{
        
            self.endSession()
        }
    }
    
    func endSession(){
        
        //pass values
        
        AnimationKit.fadeInView(self.effectView)
        self.showChild(self.sessionOverDialog!)
    
    }

    //MARK:- ContainerViewController delegate functions
    
    func didStartLesson(numberOfWords: Int) {
        
        self.removeChild(self.startDialog!)
        AnimationKit.fadeOutView(self.effectView)
        
        self.getVocabulary(numberOfWords)
        self.getWords()
        
    }
    
    @IBAction func enterAnswer(sender: AnyObject) {
        
        let button = sender as! UIButton
        
        if(button.titleLabel!.text == "ENTER"){
            
            if(self.answer == self.userInput.text){
                
                self.resultIconContainer.image = self.correctImage
                self.correctAnswers += 1
            }
            
            else{
                
                self.resultIconContainer.image = self.wrongImage
            
            }
            
            AnimationKit.fadeInView(self.resultIconContainer)
            button.titleLabel!.text = "NEXT"
        
        }
        
        else{
            
            self.getWords()
            AnimationKit.fadeOutView(self.resultIconContainer)
            button.titleLabel!.text = "ENTER"
            
        }
    }
    
    //MARK:- ChildViewController display helper functions

    func showChild(viewController:UIViewController){
        
        self.addChildViewController(viewController)
        self.dialogContainer.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        self.view.setNeedsDisplay()
        
        self.dialogContainer.hidden = false
        AnimationKit.fadeInView(self.dialogContainer)
    
    }
    
    func removeChild(viewController:UIViewController){

        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        viewController.didMoveToParentViewController(nil)
        self.view.setNeedsDisplay()
    }
}