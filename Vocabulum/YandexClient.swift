//
//  YandexClient.swift
//  yandex-api-tester
//
//  Created by Johannes Eichler on 19.08.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit


protocol YandexClientDelegate {
    
    func didFetchAllLanguages()

}

class YandexClient: SimpleNetworking {
    
    var isFetching = false
    var delegate:YandexClientDelegate?
    var languageModels:Set<Language>?
    
    var languageRelationDictionary: [String:Set<String>]?
    
    var languageCodes:[String]?
    
    let YANDEX_LANG_URL = "https://dictionary.yandex.net/api/v1/dicservice.json/getLangs"
    let API_KEY = "dict.1.1.20150819T191226Z.b8b1f773ba67a7bb.cd98fb0bfda9e8bcf0c44e00b77f3d3f6860c2e9"
    
    
    
    
    func fetchAvailableLanguages(){
        
        self.sendGETRequest(YANDEX_LANG_URL, GETData: ["key" : API_KEY], headerValues: nil) { (result, error) -> Void in
            //response: ["ru-ru", "ru-en", "ru-pl",.etc...]
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                var parsedLanguageList:[String]
                
                
                
                do {
                    parsedLanguageList = try NSJSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.MutableLeaves) as! [String]
                } catch let error as NSError {
                
                    print(error)
                }
                
                for langPair in parsedLanguageList {
                    
                    //Process the string
                    
                    var languageStrings = langPair.componentsSeparatedByString("-")
                    if(languageStrings[0] == languageStrings[1]){continue}//Languages must not be related to themselves, at least not in this app
                    
                    for idx in 0...languageStrings.count - 1 {
                        
                        if((self.languageRelationDictionary?.keys.contains({ (element: String) -> Bool in
                            element == languageStrings[idx]
                        })) == false){
                            
                            self.languageRelationDictionary![languageStrings[idx]]! = Set<String>()
                            self.languageRelationDictionary![languageStrings[idx]]!.insert(languageStrings[(idx + 1) % 2])
                            
                        }
                        
                        else {
                            self.languageRelationDictionary![languageStrings[idx]]!.insert(languageStrings[(idx + 1) % 2])
                        }
                    }
                }
                
                
                for key in self.languageRelationDictionary!.keys {
                    
                    let newLanguage = Language(langCode: key)
                    
                    newLanguage.addAvailableTranslationSet(self.languageRelationDictionary![key])
                
                
                }
                
                self.delegate?.didFetchAllLanguages()
                
            })
            
            
            
        }
    }
    
    func getVocabularyForWord(word:String, completion:(translation:String?, error:NSError?) -> Void){
        
        let requestData = ["key" : apiKey, "lang" : languageCombination, "text" :  word]
        
        
        self.sendGETRequest(yandexURL, GETData: requestData, headerValues: nil) { (result, error) -> Void in
            
            let parsedJSON = (try! NSJSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.MutableContainers)) as! [String: AnyObject]
            
            

            let completeResult = parsedJSON["def"] as! [[String: AnyObject]]
            let translationList = completeResult[0] as [String : AnyObject]
            let directTranslation = translationList["tr"] as! [[String : AnyObject]]
            let translation = directTranslation[0]["text"] as! String

            
            completion(translation: translation,error: error)
            
        }
    
    }
   
}
