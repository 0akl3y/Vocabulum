//
//  TrainingViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 06.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class TrainingViewController: UIViewController, StartBoxDelegate,ResultDialogDelegate, UITextFieldDelegate {

    @IBOutlet var resultIconContainer: UIImageView!
    @IBOutlet var wordLabel: UILabel!

    @IBOutlet var userInput: UITextField!
    @IBOutlet var enterButton: UIButton!
    
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var dialogContainer: UIView!
    
    @IBOutlet var score: UILabel!
    @IBOutlet var correctionLabel: UILabel!
    
    var wordNumber = 0
    
    var errorHandler:ErrorHandler?
    var wordsForTraining = [Word]()
    
    var answer:String?
    var question:String?
        
    var lesson:Lesson?
    var startDialog:StartBoxViewController?
    var sessionOverDialog:TrainingOverViewController?
    
    var correctAnswers:Int = 0
    
    var currentWord:Word?
    
    let correctImage = UIImage(named: "correct")
    let wrongImage = UIImage(named: "wrong")
    
    var showAnswerMode = false
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startDialog = StartBoxViewController(nibName: "StartBox", bundle: nil)        
        self.sessionOverDialog = TrainingOverViewController(nibName: "EndBox", bundle: nil)
        
        self.errorHandler = ErrorHandler(targetVC: self)
        
        self.startDialog!.delegate = self
        self.sessionOverDialog!.delegate = self
        
        self.userInput.delegate = self
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.correctAnswers = 0
        self.resultIconContainer.alpha = 0
        self.score.text = " "
        self.correctionLabel.alpha = 0
        
        self.effectView.alpha = 1

        if(self.lesson?.lessonToWord.count == 0){
            
            self.errorHandler?.displayErrorString("This lesson has no vocabulary yet")
        }

        else{
            
            self.showChild(self.startDialog!)
        }
    }
    
    
    
    //MARK:- Fetch Vocabulary
    
    func getVocabulary(numberOfWords: Int){
        
        //Gets the words for the training, if numberOfWords > available entries. the words might be asked mutliple times
        
        let sortDescriptor = NSSortDescriptor(key: "difficulty", ascending: true)
        let words = self.lesson?.lessonToWord.sortedArrayUsingDescriptors([sortDescriptor])
        
        for number in 0...(numberOfWords - 1) {
            
            let currentWord = words![(number % words!.count)]
            self.wordsForTraining.append(currentWord as! Word)
            
        }
    }
    
    func getWords(){
        
        //Gets question & answer from the array of words
        
        if let word = self.wordsForTraining.popLast(){
            
            self.currentWord = word
            let coinflip = Int(arc4random() % 2)
            
            var wordPair = [word.translation, word.word]
            self.question = wordPair[coinflip]
            wordPair.removeAtIndex(coinflip)
            self.answer = wordPair[0]
            
            self.wordLabel.text = self.question
        }
        
        else{
        
            self.endSession()
        }
    }
    
    func endSession(){
        
        AnimationKit.fadeInView(self.effectView)
        
        self.sessionOverDialog?.numberOfWords = (self.defaults.valueForKey("numberOfVocabulary") as! Int)
        self.sessionOverDialog?.correctAnswers = self.correctAnswers
        self.showChild(self.sessionOverDialog!)
    
    }

    //MARK:- ContainerViewController delegate functions
    
    func didStartLesson(numberOfWords: Int) {
        
        self.removeChild(self.startDialog!)
        AnimationKit.fadeOutView(self.effectView)
        
        self.getVocabulary(numberOfWords)
        self.getWords()
        
    }
    
    func didTapAgain() {
        self.removeChild(self.sessionOverDialog!)
        AnimationKit.fadeOutView(self.effectView)
        
        self.getVocabulary(self.defaults.valueForKey("numberOfVocabulary") as! Int)
        self.getWords()
        
    }
    
    
    //MARK:- Actions
    
    @IBAction func enterAnswer(sender: AnyObject) {
        
        let button = sender as! UIButton
        
        if(!self.showAnswerMode){
            
            self.wordNumber += 1
            
            if(self.answer == self.userInput.text){
                
                self.resultIconContainer.image = self.correctImage
                self.correctAnswers += 1
                self.currentWord?.difficulty = self.currentWord?.difficulty == 0 ? 0 : (self.currentWord?.difficulty)! - 1
                
            }
            
            else{
                
                self.correctionLabel.text = self.answer
                
                self.resultIconContainer.image = self.wrongImage
                AnimationKit.fadeInView(self.correctionLabel)
                
                self.currentWord?.difficulty = self.currentWord?.difficulty == 3 ? 3 : (self.currentWord?.difficulty)! + 1
            
            }
            
            AnimationKit.fadeOutView(self.userInput)
            self.userInput.text = ""
            
            AnimationKit.fadeInView(self.resultIconContainer)
            button.setTitle("NEXT", forState: UIControlState.Normal)
            self.score.text = "\(self.correctAnswers)/\(self.wordNumber)"
            
            
            self.showAnswerMode = true
        
        }
        
        else{
            
            self.getWords()
            AnimationKit.fadeOutView(self.resultIconContainer)
            AnimationKit.fadeOutView(self.correctionLabel)
            AnimationKit.fadeInView(self.userInput)
            
            button.setTitle("ENTER", forState: UIControlState.Normal)
            self.showAnswerMode = false
            
        }
    }
    
    @IBAction func cancelTraining(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK:- ChildViewController display helper functions

    func showChild(viewController:UIViewController){
        
        self.dialogContainer.hidden = false
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
        self.dialogContainer.hidden = true
        self.view.setNeedsDisplay()
        
    }
    
    //MARK:- TextField delegate methoden
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        
    }
}