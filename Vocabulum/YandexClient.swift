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
    
    var isFetching = false
    var delegate:YandexClientDelegate?
    var fetchedLanguages:[Language]?
    
    var langCodeLanguageMapping = [String:Language]()
    
    var currentFetchRequest:NSFetchRequest<NSFetchRequestResult>?
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
        let entityDescription = NSEntityDescription.entity(forEntityName: "Language", in: self.context)
        let sortDescriptior = NSSortDescriptor(key: "languageName", ascending: true)
        
        self.currentFetchRequest?.entity = entityDescription
        self.currentFetchRequest?.sortDescriptors = [sortDescriptior]
        
            do {
                
                if let languages = try self.context.fetch(self.currentFetchRequest!) as? [Language]{
                    
                    self.fetchedLanguages = languages
                    self.getDictionaryOfExistingLanguages()
                    
                }
            }
                
            catch {
                
                print("\(error)")
            }
        
        //}
        
    }
    
    fileprivate func checkCollectionForLanguageCode<T: Sequence>(_ collection: T?, langCode:String) -> Bool{
        
        if let currentCollection = collection {
            
            return currentCollection.contains(where: { (element) -> Bool in
                
                guard let language = element as? Language else{
                    
                    return false
                
                }
                return language.langCode == langCode
            })
        }
        
        return false
    }
    
    fileprivate func getDictionaryOfExistingLanguages(){
        
        if let languages = self.fetchedLanguages {
            
            for entity in languages {
                
                let key = entity.langCode
                self.langCodeLanguageMapping[key] = entity
                
            }
        }
    }

    func fetchAvailableLanguages(_ completion:(()->())?){
        
        self.isFetching = true
        
        self.getPersistedLanguages()
        
        self.sendGETRequest(YANDEX_LANG_URL, GETData: ["key" : API_KEY], headerValues: nil) { (result, error) -> Void in
            
            if(error != nil){
                
                print("Internet connection could not be etablished, continuing in offline mode: \(error)")
                return
            }
            
            DispatchQueue.main.async(execute:{ () -> Void in
                
                var parsedLanguageList:[String]?
                
                do {
                    parsedLanguageList = try JSONSerialization.jsonObject(with: result! as Data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String]
                } catch let error as NSError {
                
                    print("There was an error parsing the JSON response \(error)")
                    parsedLanguageList = nil
                }
                
                for langPair in parsedLanguageList! {
                    
                    //Process the string
                    
                    var languageStrings = langPair.components(separatedBy: "-")
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
                
            completion?()
                
            CoreDataStack.sharedObject().saveContext()
            
            })
        }
    }

    func getVocabularyForWord(_ word:String, languageCombination:String, completion:@escaping (_ translation:String?, _ error:Error?) -> Void){
        
        let requestData = ["key" : API_KEY, "lang" : languageCombination, "text" :  word]
        
        
        self.sendGETRequest(YANDEX_DICT_URL, GETData: requestData, headerValues: nil) { (result, error) -> Void in
            
            if(error != nil){
                completion(nil, error!)
                return
            }
            
            let parsedJSON = (try! JSONSerialization.jsonObject(with: result! as Data, options: JSONSerialization.ReadingOptions.allowFragments)) as! [String: AnyObject]

            if let completeResult = parsedJSON["def"] as? [[String: AnyObject]]{
                
                if(completeResult.count > 0){
                    
                    let directTranslation = completeResult[0]["tr"] as? [[String : AnyObject]] //Array Index is out of bounds if translation is not found
                    let translation = directTranslation![0]["text"] as! String
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        completion(translation,error)
                        
                    })
                }
                
                else{
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        completion("Could no find a translation for: \(word)",nil)
                    })
                }
            }
        }
    }
}
