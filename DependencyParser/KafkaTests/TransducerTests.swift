//
//  TransducerTests.swift
//  DependencyParserTests
//
//  Created by Khush Jammu on 29/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import XCTest
import CoreML
@testable import DependencyParser

class TransducerTests: XCTestCase {
    let testSentenceWithPos = [("In", "ADP"), ("an", "DET"), ("Oct.", "PROPN"), ("19", "NUM"), ("review", "NOUN"), ("of", "ADP"), ("``", "PUNCT"), ("The", "DET"), ("Misanthrope", "NOUN"), ("''", "PUNCT"), ("at", "ADP"), ("Chicago", "PROPN"), ("'s", "PART"), ("Goodman", "PROPN"), ("Theatre", "PROPN"), ("-LRB-", "PUNCT"), ("``", "PUNCT"), ("Revitalized", "VERB"), ("Classics", "NOUN"), ("Take", "VERB"), ("the", "DET"), ("Stage", "NOUN"), ("in", "ADP"), ("Windy", "PROPN"), ("City", "PROPN"), (",", "PUNCT"), ("''", "PUNCT"), ("Leisure", "NOUN"), ("&", "CONJ"), ("Arts", "NOUN"), ("-RRB-", "PUNCT"), (",", "PUNCT"), ("the", "DET"), ("role", "NOUN"), ("of", "ADP"), ("Celimene", "PROPN"), (",", "PUNCT"), ("played", "VERB"), ("by", "ADP"), ("Kim", "PROPN"), ("Cattrall", "PROPN"), (",", "PUNCT"), ("was", "AUX"), ("mistakenly", "ADV"), ("attributed", "VERB"), ("to", "ADP"), ("Christina", "PROPN"), ("Haag", "PROPN"), (".", "PUNCT")]
    
    let transducer: Transducer = Transducer(
        wordList: TransducerData.wordList,
        tagList: TransducerData.tagList,
        deprelList: TransducerData.deprelList
    )

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_pp2feat() throws {
        // test complete should be true
        let pp_complete = PartialParse(sentence: self.testSentenceWithPos)
                
        pp_complete.stack = [0]
        pp_complete.next = 1
        pp_complete.arcs = []
        
        // 1,18 or 18,1?
        let correct_word_ids = try MLMultiArray(shape: [1,18], dataType: .float32)
        let corerect_word_ids_values = [0,4002,4002,593,1237,796,4002,4002,4002,4002,4002,4002,4002,4002,4002,4002,4002,4002]
        for (i, x) in corerect_word_ids_values.enumerated() {
            correct_word_ids[i] = NSNumber(floatLiteral: Double(x))
        }
        
        let correct_tag_ids = try MLMultiArray(shape: [1,18], dataType: .float32)
        let correct_tag_ids_values = [0,19,19,2,6,12,19,19,19,19,19,19,19,19,19,19,19,19]
        for (i, x) in correct_tag_ids_values.enumerated() {
            correct_tag_ids[i] = NSNumber(floatLiteral: Double(x))
        }
        
        let correct_deprel_ids = try MLMultiArray(shape: [1,12], dataType: .float32)
        let correct_deprel_ids_values = [41,41,41,41,41,41,41,41,41,41,41,41]
        for (i, x) in correct_deprel_ids_values.enumerated() {
            correct_deprel_ids[i] = NSNumber(floatLiteral: Double(x))
        }
        
        let returned = self.transducer.pp2feat(partial: pp_complete)
        print(returned)
        XCTAssert(returned.0 == correct_word_ids)
        XCTAssert(returned.1 == correct_tag_ids)
        XCTAssert(returned.2 == correct_deprel_ids)
        
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
