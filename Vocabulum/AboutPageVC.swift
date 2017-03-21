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
        
        let url = Bundle.main.url(forResource: "about-page", withExtension: "html")
        self.webView.loadRequest(URLRequest(url: url!))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK:- WebView Delegate Methods
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if( navigationType == UIWebViewNavigationType.linkClicked){
            
            UIApplication.shared.openURL(request.url!)
            return false
        
        }
    
        return true
    }
}
