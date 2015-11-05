//
//  YandexClient.swift
//  yandex-api-tester
//
//  Created by Johannes Eichler on 19.08.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import CoreData


protocol YandexClientDelegate {
    
    func didFetchAllLanguages()

}

class YandexClient: SimpleNetworking {
    
    
    let YANDEX_LANG_URL = "https://dictionary.yandex.net/api/v1/dicservice.json/getLangs"
    let YANDEX_DICT_URL = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup"
    
    let API_KEY = "dict.1.1.20150819T191226Z.b8b1f773ba67a7bb.cd98fb0bfda9e8bcf0c44e00b77f3d3f6860c2e9"
    
    var isFetching = false
    var delegate:YandexClientDelegate?
    var fetchedLanguages:[Language]?
    
    var langCodeLanguageMapping = [String:Language]()
    
    var currentFetchRequest:NSFetchRequest?
    var context:NSManagedObjectContext = CoreDataStack.sharedObject().managedObjectContext!
    var languageCodes:[String]?
    
    
    class func sharedObject() -> YandexClient {
        
        struct sharedInstance {
            
            static var sharedObject = YandexClient()
            
        }
        
        return sharedInstance.sharedObject
        
    }
    
    
    func getPersistedLanguages(){
        
        //get the persisted language models from store.
        self.currentFetchRequest = NSFetchRequest(entityName: "Language")
        let entityDescription = NSEntityDescription.entityForName("Language", inManagedObjectContext: self.context)
        let sortDescriptior = NSSortDescriptor(key: "languageName", ascending: true)
        
        self.currentFetchRequest?.entity = entityDescription
        self.currentFetchRequest?.sortDescriptors = [sortDescriptior]
        
            do {
                
                if let languages = try self.context.executeFetchRequest(self.currentFetchRequest!) as? [Language]{
                    
                    self.fetchedLanguages = languages
                    self.getDictionaryOfExistingLanguages()
                    
                }
                
            }
                
            catch {
                
                print("Failed to fetch languages")
            }
        
        //}
        
    }
    
    func checkCollectionForLanguageCode<T: SequenceType>(collection: T?, langCode:String) -> Bool{
        
        if let currentCollection = collection {
            
            return currentCollection.contains({ (element) -> Bool in
                
                let language = element as! Language
                return language.langCode == langCode
            })
        
        }
        
        return false
    }
    
    func getDictionaryOfExistingLanguages(){
        
        if let languages = self.fetchedLanguages {
            
            for entity in languages {
                
                let key = entity.langCode
                self.langCodeLanguageMapping[key] = entity
                
            }
        
        }
    }
    

    func fetchAvailableLanguages(){
        
        self.isFetching = true
        
        self.getPersistedLanguages()
        
        self.sendGETRequest(YANDEX_LANG_URL, GETData: ["key" : API_KEY], headerValues: nil) { (result, error) -> Void in
            
            
            if(error != nil){
                
                print("Internet connection could not be etablished, continuing in offline mode: \(error)")
                return
            }
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                var parsedLanguageList:[String]?
                
                do {
                    parsedLanguageList = try NSJSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.MutableLeaves) as? [String]
                } catch let error as NSError {
                
                    print("There was an error parsing the JSON response \(error)")
                    parsedLanguageList = nil
                }
                
                for langPair in parsedLanguageList! {
                    
                    //Process the string
                    
                    var languageStrings = langPair.componentsSeparatedByString("-")
                    if(languageStrings[0] == languageStrings[1]){continue}//Languages must not be related to themselves, at least not in this app
                    
                    for idx in 0...languageStrings.count - 1 {
                        
                            
                        if(!self.checkCollectionForLanguageCode(self.fetchedLanguages, langCode: languageStrings[idx])){
                            
                            //language is not yet in store
                            
                            let newLanguage = Language(langCode: languageStrings[idx])
                            self.langCodeLanguageMapping[languageStrings[idx]] = newLanguage
                            
                            self.fetchedLanguages!.append(newLanguage)
                            
                            if(idx == 1){ //Make sure both languages already exist before adding a relation
                                
                                let sourceLang = languageStrings[0]
                                newLanguage.addAvailabTranslation(self.langCodeLanguageMapping[sourceLang]!)
                            }
                            
                        }
                        
                        else{
                            
                            
                            if(idx == 1){
                                
                                let currentLangString = languageStrings[idx]
                                let currentLang = self.langCodeLanguageMapping[currentLangString]
                                
                                let otherLangString = languageStrings[0]
                                
                                if(!self.checkCollectionForLanguageCode(currentLang!.availableTranslations, langCode: otherLangString)){
                                    
                                    let otherLang = self.langCodeLanguageMapping[otherLangString]
                                    currentLang?.addAvailabTranslation(otherLang!)
                                    
                                }
                            
                            }
                        }
                
                
                    }
                    
                }
                
            self.isFetching = false
            self.delegate?.didFetchAllLanguages()
            CoreDataStack.sharedObject().saveContext()
            
            })
            
        }
    }
    

    func getVocabularyForWord(word:String, languageCombination:String, completion:(translation:String?, error:NSError?) -> Void){
        
        let requestData = ["key" : API_KEY, "lang" : languageCombination, "text" :  word]
        
        
        self.sendGETRequest(YANDEX_DICT_URL, GETData: requestData, headerValues: nil) { (result, error) -> Void in
            
            let parsedJSON = (try! NSJSONSerialization.JSONObjectWithData(result!, options: NSJSONReadingOptions.MutableContainers)) as! [String: AnyObject]

            let completeResult = parsedJSON["def"] as! [[String: AnyObject]]
            let translationList = completeResult[0] as [String : AnyObject]
            let directTranslation = translationList["tr"] as! [[String : AnyObject]]
            let translation = directTranslation[0]["text"] as! String
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                completion(translation: translation,error: error)
                
            })
        }    
    }

   
}
