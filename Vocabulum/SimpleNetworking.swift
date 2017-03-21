//
//  SimpleNetworking.swift
//  yandex-api-tester
//
//  Created by Johannes Eichler on 19.05.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit

class SimpleNetworking: NSObject {
   
    var sharedSession: URLSession {
        
        get{
            
            return URLSession.shared
        }
    }
    
    func escapeToURL(_ targetURL: String, methodCall: [String: Any]?) -> String{
        
        //takes the methodCall array containing the method call and all parameters and returns the complete URL for the GET request
        
        var parsedURLString = [String]()
        
        for (key, value) in methodCall! {
            
            let currentValue: String = "\(value)".addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let methodElement = "\(key)" + "=" + "\(currentValue)"
            
            parsedURLString.append(methodElement)
            
        }
        
        let getRequestPart = parsedURLString.joined(separator: "&")
        let completeURL = targetURL + "?" + getRequestPart
        
        return completeURL
    }
    
    func sendJSONRequest(_ targetURL: String, method: String, additionalHeaderValues:[String:String]?, bodyData: [String:AnyObject]?, completion:@escaping (_ result:Data?, _ error:Error?) -> Void){
        
        var request = URLRequest(url: URL(string: targetURL)!)
        
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        if let additionalHeaderFields = additionalHeaderValues {
            
            for (key, value) in additionalHeaderFields{
                
                request.addValue(value , forHTTPHeaderField: key)
            
            }        
        }
        
        
        if(bodyData != nil){
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyData!, options: [])
            } catch let error as NSError {
                print(error)
                request.httpBody = nil
            }
        
        }
        
        
        
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if error != nil { // Handle error…
                completion(nil, error! as NSError?)
                return
            }
            
            //let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            completion(data, error)
            
        }) 
        task.resume()
        
        
    }
    
    
    func sendGETRequest(_ targetURL: String, GETData: [String:Any]?, headerValues:[String: String]?, completion:@escaping (_ result:Data?, _ error:Error?) -> Void) {
            
            var requestURL: URL = URL(string: targetURL)!
        
            if(GETData != nil){

                let requestURLString: String = self.escapeToURL(targetURL, methodCall: GETData)
                requestURL = URL(string: requestURLString)!
            }
        
            var currentRequest = URLRequest(url: requestURL)
        
            if let additionalHeaderFields = headerValues {
                
                for (key, value) in additionalHeaderFields{
                    
                    currentRequest.addValue(value , forHTTPHeaderField: key)
                    
                }
                
            }
        
            let task = sharedSession.dataTask(with: currentRequest, completionHandler: { data, response, error in
            
            if error != nil {
                completion(nil, error!)
                return
            }
            
            completion(data, error)
            
        }) 
        task.resume()
        
            
    }
    
}
