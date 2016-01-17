//
//  AboutPageVC.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 17.01.16.
//  Copyright © 2016 Eichler. All rights reserved.
//

import UIKit

class AboutPageVC: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSBundle.mainBundle().URLForResource("about-page", withExtension: "html")
        self.webView.loadRequest(NSURLRequest(URL: url!))
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK:- WebView Delegate Methods
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if( navigationType == UIWebViewNavigationType.LinkClicked){
            
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        
        }
    
        return true
    }

}
