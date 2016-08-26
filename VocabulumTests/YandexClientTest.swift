//
//  YandexClientTest.swift
//  VocabulumTests
//
//  Created by Johannes Eichler on 14.09.15.
//  Copyright (c) 2015 Eichler. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import Foundation

@testable import Vocabulum

class YandexClientTest: XCTestCase, TestStorageAvailability  {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchVocabulary() {
        let expectation = expectationWithDescription("fetchVocabularyExpectation")
        yandexClient.fetchAvailableLanguages {
            
            self.yandexClient.getVocabularyForWord("Pferd", languageCombination: "de-en", completion: { (translation, error) in
                print(translation!)
                
                XCTAssert(translation == "horse", "Failed to fetch correct vocabulary.")
                expectation.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(10.0) { (error) in
            if let err = error {
                print(err)
            }
        }
    }
    
    
    func testFetchLanguages() {
        
        let localYandexClient = self.yandexClient
        
        let expectation = expectationWithDescription("fetchLangPairsExpecation")
        localYandexClient.fetchAvailableLanguages {
            
            let languageList:[Language]? = localYandexClient.fetchedLanguages
            XCTAssert(languageList?.count > 0, "Could not fetch available languages")
            XCTAssert(localYandexClient.langCodeLanguageMapping["de"] == "German", "Languages were not mapped correctly")
            
            expectation.fulfill()
            
        }
        
        waitForExpectationsWithTimeout(30.0) { (error) in
            if let err = error {
                print(err)
            }
        }
    
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
