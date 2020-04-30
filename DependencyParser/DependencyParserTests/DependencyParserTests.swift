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
    
    let testSentenceWithPos = [("In", "ADP"), ("an", "DET"), ("Oct.", "PROPN"), ("19", "NUM"), ("review", "NOUN"), ("of", "ADP"), ("``", "PUNCT"), ("The", "DET"), ("Misanthrope", "NOUN"), ("''", "PUNCT"), ("at", "ADP"), ("Chicago", "PROPN"), ("'s", "PART"), ("Goodman", "PROPN"), ("Theatre", "PROPN"), ("-LRB-", "PUNCT"), ("``", "PUNCT"), ("Revitalized", "VERB"), ("Classics", "NOUN"), ("Take", "VERB"), ("the", "DET"), ("Stage", "NOUN"), ("in", "ADP"), ("Windy", "PROPN"), ("City", "PROPN"), (",", "PUNCT"), ("''", "PUNCT"), ("Leisure", "NOUN"), ("&", "CONJ"), ("Arts", "NOUN"), ("-RRB-", "PUNCT"), (",", "PUNCT"), ("the", "DET"), ("role", "NOUN"), ("of", "ADP"), ("Celimene", "PROPN"), (",", "PUNCT"), ("played", "VERB"), ("by", "ADP"), ("Kim", "PROPN"), ("Cattrall", "PROPN"), (",", "PUNCT"), ("was", "AUX"), ("mistakenly", "ADV"), ("attributed", "VERB"), ("to", "ADP"), ("Christina", "PROPN"), ("Haag", "PROPN"), (".", "PUNCT")]
    
    let transducer: Transducer = Transducer(
               wordList: TransducerData.wordList,
               tagList: TransducerData.tagList,
               deprelList: TransducerData.deprelList
           )
    
    let parser = Parser(wordList: TransducerData.wordList, tagList: TransducerData.tagList, deprelList: TransducerData.deprelList)
    
    func testPartialParse_init() throws {
       let partialParserTest = PartialParse(sentence: self.testSentenceWithPos)

    }
    
    func testPOS() throws {
        print(parser.POSTag(sentence: "In an Oct. 19 review of \"The Misanthrope \"at Chicago's Goodman Theatre (\"Revitalized Classics Take the Stage in Windy City , \"Leisure & Arts ) , the role of Celimene , played by Kim Cattrall , was mistakenly attributed to Christina Haag ."))
    }
    
    func testvec2deprel() throws {
        let collection: [Float32] = [14.15625,-12.75781,-15.72656,-17.01562,-11.20312,-5.386719,-6.378906,-19.125,-5.65625,-13.99219,-1.739258,-3.699219,-10.67188,-12.15625,-6.050781,-16.09375,-9.984375,-5.886719,-12.25,-17.09375,-3.677734,-4.222656,-12.82812,-10.65625,-8.226562,-8.703125,-16.15625,-5.816406,-15.07812,-10.28125,-8.992188,-9.320312,-6.996094,-11.01562,-3.558594,-6.890625,-9.351562,-13.02344,-5.824219,-14.5,-11.35938,-15.08594,-15.14844,-9.015625,-7.902344,-6.710938,-2.71875,-6.464844,-5.777344,-7.917969,-10.19531,-7.847656,-11.32812,-15.29688,-6.300781,-8.75,-7.03125,-4.023438,-8.257812,-16.3125,-16.46875,-1.148438,-5.609375,-16.04688,-11.17969,-4.855469,-10.09375,-6.960938,-5.65625,-4.128906,-7.066406,-6.246094,-7.90625,-19.75,-8.257812,-7.484375,-18.51562,-9.804688,-10.39844,-1.605469,-6.757812,-5.996094,-15.75781]
        let td_vec = try MLMultiArray(collection)
        print(transducer.td_vec2trans_deprel(td_vec: td_vec))
    }
    
    func testInternalPredict() throws {
        let wordIDs = transducer.convertArrayToML(array: [0, 4002, 4002, 1087, 2360, 4001, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002])
        let tagIDs = transducer.convertArrayToML(array: [0, 19, 19, 11, 14, 12, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19])
        let deprelIDs = transducer.convertArrayToML(array: [41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41])
        print(parser._predict(wordIDs, tagIDs, deprelIDs))
    }
    
    func testPredict() throws {
        print(parser.predict(sentences: [testSentenceWithPos]))
    }
    
    func testPredictOnSentences() throws {
        print(parser.predictOnSentences(sentences: ["Arya is a good boy."]))
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
