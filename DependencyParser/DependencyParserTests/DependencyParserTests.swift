//
//  DependencyParserTests.swift
//  DependencyParserTests
//
//  Created by Taichi Kato on 28/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import XCTest
import CoreML
@testable import DependencyParser

class DependencyParserTests: XCTestCase {
    let parser: Parser = Parser()
    let testSentenceWithPos = [("In", "ADP"), ("an", "DET"), ("Oct.", "PROPN"), ("19", "NUM"), ("review", "NOUN"), ("of", "ADP"), ("``", "PUNCT"), ("The", "DET"), ("Misanthrope", "NOUN"), ("''", "PUNCT"), ("at", "ADP"), ("Chicago", "PROPN"), ("'s", "PART"), ("Goodman", "PROPN"), ("Theatre", "PROPN"), ("-LRB-", "PUNCT"), ("``", "PUNCT"), ("Revitalized", "VERB"), ("Classics", "NOUN"), ("Take", "VERB"), ("the", "DET"), ("Stage", "NOUN"), ("in", "ADP"), ("Windy", "PROPN"), ("City", "PROPN"), (",", "PUNCT"), ("''", "PUNCT"), ("Leisure", "NOUN"), ("&", "CONJ"), ("Arts", "NOUN"), ("-RRB-", "PUNCT"), (",", "PUNCT"), ("the", "DET"), ("role", "NOUN"), ("of", "ADP"), ("Celimene", "PROPN"), (",", "PUNCT"), ("played", "VERB"), ("by", "ADP"), ("Kim", "PROPN"), ("Cattrall", "PROPN"), (",", "PUNCT"), ("was", "AUX"), ("mistakenly", "ADV"), ("attributed", "VERB"), ("to", "ADP"), ("Christina", "PROPN"), ("Haag", "PROPN"), (".", "PUNCT")]

//    override func setUpWithError() throws {
//
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let array1 = try MLMultiArray(shape: [1,18], dataType: .float32)
        let array_1 = [0, 4002, 4002, 1087, 2360, 4001, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002]
        for (i, x) in array_1.enumerated() {
            array1[i] = NSNumber(floatLiteral: Double(x))
        }

        let array2 = try MLMultiArray(shape: [1,18], dataType: .float32)
        let array_2 = [0, 19, 19, 11, 14, 12, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19]
        for (i, x) in array_2.enumerated() {
            array2[i] = NSNumber(floatLiteral: Double(x))
        }

        let array3 = try MLMultiArray(shape: [1,12], dataType: .float32)
        let array_3 = [41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41]
        for (i, x) in array_3.enumerated() {
            array3[i] = NSNumber(floatLiteral: Double(x))
        }
        let preds = self.parser.predict(wordIDs: array1, tagIDs: array2, deprelIDs: array3)
        print(preds)
        
    }
    
    func testPartialParse_init() throws {
        let partialParserTest = PartialParse(sentence: self.testSentenceWithPos)
    }
    
    
    func testPartialParse_complete() throws {
        // test complete should be true
        var pp_complete = PartialParse(sentence: self.testSentenceWithPos)
        
        pp_complete.stack = [0]
        pp_complete.next = 50
        pp_complete.arcs = [(5, 4, "nummod"), (5, 3, "compound"), (5, 2, "det"), (5, 1, "case"), (9, 8, "det"), (9, 7, "punct"), (9, 6, "case"), (9, 10, "punct"), (12, 13, "case"), (15, 14, "compound"), (15, 12, "nmod:poss"), (15, 11, "case"), (9, 15, "nmod"), (5, 9, "nmod"), (19, 18, "amod"), (20, 19, "nsubj"), (20, 17, "punct"), (20, 16, "punct"), (22, 21, "det"), (20, 22, "dobj"), (25, 24, "compound"), (25, 23, "case"), (20, 25, "nmod"), (20, 26, "punct"), (20, 27, "punct"), (28, 29, "cc"), (28, 30, "conj"), (20, 28, "dep"), (20, 31, "punct"), (5, 20, "dep"), (34, 33, "det"), (36, 35, "case"), (34, 36, "nmod"), (34, 37, "punct"), (41, 40, "compound"), (41, 39, "case"), (38, 41, "nmod"), (34, 38, "acl"), (34, 42, "punct"), (45, 44, "advmod"), (45, 43, "auxpass"), (45, 34, "nsubjpass"), (45, 32, "punct"), (45, 5, "nmod"), (48, 47, "compound"), (48, 46, "case"), (45, 48, "nmod"), (45, 49, "punct"), (0, 45, "root")]
        
        XCTAssert(pp_complete.complete)
        
        // test complete shouldn't be true
        
        var pp_incomplete = PartialParse(sentence: self.testSentenceWithPos)
        
        pp_incomplete.stack = [0, 5, 6]
        pp_incomplete.next = 7
        pp_incomplete.arcs = [(5, 4, "nummod"), (5, 3, "compound"), (5, 2, "det"), (5, 1, "case")]
        
        XCTAssert(!pp_incomplete.complete)
    }
    
    func testPartialParser_parse_step() throws {
        // definitely can (isolated)
        
        var pp = PartialParse(sentence: self.testSentenceWithPos)
    
        pp.stack = [0]
        pp.next = 1
        pp.arcs = []
        
        pp.parse_step(transition_id: 2, deprel: nil)
        
        XCTAssert(pp.stack == [0,1])
        XCTAssert(pp.next == 2)
        XCTAssert(pp.arcs.isEmpty)
        
        // add check where deprel isn't nil
        
        
    }
    
    func testPartialParser_get_n_leftmost_deps() throws {
        // test where return non-empty, n=1
        var pp_nonempty = PartialParse(sentence: self.testSentenceWithPos)
        pp_nonempty.stack = [0, 5, 9, 11, 15]
        pp_nonempty.next = 16
        pp_nonempty.arcs = [(5, 4, "nummod"), (5, 3, "compound"), (5, 2, "det"), (5, 1, "case"), (9, 8, "det"), (9, 7, "punct"), (9, 6, "case"), (9, 10, "punct"), (12, 13, "case"), (15, 14, "compound"), (15, 12, "nmod:poss")]

        XCTAssert(pp_nonempty.get_n_leftmost_deps(sentence_idx: 12, n: 1) == [13])
        
        // test where return is empty, n=1
        
        var pp_empty = PartialParse(sentence: self.testSentenceWithPos)
        pp_empty.stack = [0, 1, 2, 3, 5]
        pp_empty.next = 6
        pp_empty.arcs = [(5, 4, "nummod")]
        
        XCTAssert(pp_empty.get_n_leftmost_deps(sentence_idx: 4, n: 1) == [])
        
        
        // add test cases for when n =/= 1
    }
    
    func testPartialParser_get_n_rightmost_deps() throws {
        var pp_nonempty = PartialParse(sentence: self.testSentenceWithPos)
        pp_nonempty.stack = [0, 5, 9]
        pp_nonempty.next = 16
        pp_nonempty.arcs =  [(5, 4, "nummod"), (5, 3, "compound"), (5, 2, "det"), (5, 1, "case"), (9, 8, "det"), (9, 7, "punct"), (9, 6, "case"), (9, 10, "punct"), (12, 13, "case"), (15, 14, "compound"), (15, 12, "nmod:poss"), (15, 11, "case"), (9, 15, "nmod")]
        
        XCTAssert(pp_nonempty.get_n_rightmost_deps(sentence_idx: 15, n: 1) == [14])
        
        // add empty case

    }
    
    func testPartialParser_get_oracle() throws {
        
    }
    
    func testPartialParser_parse() throws {
        
    }
        
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
