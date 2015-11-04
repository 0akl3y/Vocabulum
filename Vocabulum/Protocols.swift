//
//  Protocols.swift
//  Vocabulum
//
//  Created by Johannes Eichler on 04/11/15.
//  Copyright © 2015 Eichler. All rights reserved.
//

import UIKit

protocol LanguageObject {
    // There are two types of language objects. Languages (Language) fetched from Yandex are persisted. Custom languages without Yandex support are not persisted.
    
    var languageName: String { get set }
    var langCode: String { get set }
    var translatedLanguageName:String { get set }

}
