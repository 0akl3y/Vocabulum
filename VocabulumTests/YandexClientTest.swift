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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class YandexClientTest: XCTestCase, TestStorageAvailability  {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchVocabulary() {
        let expectation = self.expectation(description: "fetchVocabularyExpectation")
        yandexClient.fetchAvailableLanguages {
            
            self.yandexClient.getVocabularyForWord("Pferd", languageCombination: "de-en", completion: { (translation, error) in
                print(translation!)
                
                XCTAssert(translation == "horse", "Failed to fetch correct vocabulary.")
                expectation.fulfill()
            })
        }
        
        waitForExpectations(timeout: 10.0) { (error) in
            if let err = error {
                print(err)
            }
        }
    }
    
    
    func testFetchLanguages() {
        
        let localYandexClient = self.yandexClient
        
        let expectation = self.expectation(description: "fetchLangPairsExpecation")
        localYandexClient.fetchAvailableLanguages {
            
            let languageList:[Language]? = localYandexClient.fetchedLanguages
            XCTAssert(languageList?.count > 0, "Could not fetch available languages")
            XCTAssert(localYandexClient.langCodeLanguageMapping["de"]?.languageName ?? "" == "German", "Languages were not mapped correctly")
            
            expectation.fulfill()
            
        }
        
        waitForExpectations(timeout: 30.0) { (error) in
            if let err = error {
                print(err)
            }
        }
    
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
