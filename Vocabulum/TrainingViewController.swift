//
//  TrainingViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 06.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData

class TrainingViewController: UIViewController, StartBoxDelegate,ResultDialogDelegate {

    @IBOutlet var resultIconContainer: UIImageView!
    @IBOutlet var wordLabel: UILabel!

    @IBOutlet var userInput: UITextField!
    @IBOutlet var enterButton: UIButton!
    
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var dialogContainer: UIView!
    
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
        
        //AnimationKit.fadeInView(self.effectView)
        
        self.sessionOverDialog?.numberOfWords = (self.defaults.valueForKey("numberOfVocabulary") as! Int)
        self.sessionOverDialog?.correctAnswers = self.correctAnswers
        self.showChild(self.sessionOverDialog!)
    
    }

    //MARK:- ContainerViewController delegate functions
    
    func didStartLesson(numberOfWords: Int) {
        
        self.removeChild(self.startDialog!)
        //AnimationKit.fadeOutView(self.effectView)
        
        self.getVocabulary(numberOfWords)
        self.getWords()
        
    }
    
    func didTapAgain() {
        self.removeChild(self.sessionOverDialog!)
        
        self.getVocabulary(self.defaults.valueForKey("numberOfVocabulary") as! Int)
        self.getWords()
        
    }
    
    
    @IBAction func enterAnswer(sender: AnyObject) {
        
        let button = sender as! UIButton
        
        if(!self.showAnswerMode){
            
            if(self.answer == self.userInput.text){
                
                self.resultIconContainer.image = self.correctImage
                self.correctAnswers += 1
                self.currentWord?.difficulty = self.currentWord?.difficulty == 0 ? 0 : (self.currentWord?.difficulty)! - 1
                
            }
            
            else{
                
                self.resultIconContainer.image = self.wrongImage
                self.currentWord?.difficulty = self.currentWord?.difficulty == 3 ? 3 : (self.currentWord?.difficulty)! + 1
            
            }
            
            AnimationKit.fadeInView(self.resultIconContainer)
            button.setTitle("NEXT", forState: UIControlState.Normal)
            self.showAnswerMode = true
        
        }
        
        else{
            
            self.getWords()
            AnimationKit.fadeOutView(self.resultIconContainer)
            button.setTitle("ENTER", forState: UIControlState.Normal)
            self.showAnswerMode = false
            
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