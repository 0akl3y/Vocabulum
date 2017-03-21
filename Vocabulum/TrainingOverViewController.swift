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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.statisticLabel.text = NSLocalizedString("Correct Answers:", comment: "")  + "\(self.correctAnswers!)/\(self.numberOfWords!)"
    }
    
    @IBAction func playAgain(_ sender: AnyObject) {
        
        self.delegate?.didTapAgain()
    }

    @IBAction func cancel(_ sender: AnyObject) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
}
