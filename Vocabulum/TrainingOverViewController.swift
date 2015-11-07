//
//  TrainingOverViewController.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 06.11.15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

protocol ResultDialogDelegate {
    
    func didTapAgain()


}

class TrainingOverViewController: UIViewController {

    @IBOutlet var trainingOverTitle: UILabel!
    @IBOutlet var statisticLabel: UILabel!
    var correctAnswers: Int?
    var numberOfWords: Int?
    
    var delegate:ResultDialogDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.statisticLabel.text = "Correct Answers: \(self.correctAnswers!)/\(self.numberOfWords!)"
        
        
    }
    

    @IBAction func playAgain(sender: AnyObject) {
        
        self.delegate?.didTapAgain()
    }

    @IBAction func cancel(sender: AnyObject) {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
