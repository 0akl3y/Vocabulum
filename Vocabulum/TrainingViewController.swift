//
//  TrainingViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 06.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

class TrainingViewController: UIViewController, StartBoxDelegate {

    @IBOutlet var resultIconContainer: UIImageView!
    @IBOutlet var word: UILabel!
    @IBOutlet var userInput: UITextField!
    @IBOutlet var enterButton: UIButton!
    
    @IBOutlet var effectView: UIVisualEffectView!
    @IBOutlet var dialogContainer: UIView!
    
    var lesson:Lesson?
    var startDialog:StartBoxViewController?
    var sessionOverDialog:TrainingOverViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDialog = (self.storyboard?.instantiateViewControllerWithIdentifier("startBox") as! StartBoxViewController)
        self.sessionOverDialog = (self.storyboard?.instantiateViewControllerWithIdentifier("endBox") as! TrainingOverViewController)
        
        self.startDialog!.delegate = self
        
        
        showChild(self.startDialog!)
        // Do any additional setup after loading the view.
    }
    

    //MARK:- ContainerViewController delegate functions
    
    func didStartLesson(numberOfWords: Int) {
        //Lesson did start
    }
    
    @IBAction func enterAnswer(sender: AnyObject) {
    }
    
    //MARK:- ChildViewController display helper functions

    func showChild(viewController:UIViewController){
        
        self.addChildViewController(viewController)
        self.dialogContainer.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    
    }
    
    
    func removeChild(viewController:UIViewController){

        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        viewController.didMoveToParentViewController(nil)
    }


}
