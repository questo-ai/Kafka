//
//  RepresentationTests.swift
//  KafkaTests
//
//  Copyright © 2020 Questo AI. All rights reserved.
//

import XCTest
import CoreML
@testable import Kafka

class RepresentationTests: XCTestCase {
    let testSentence = "The leftward immediate children of the word, in the syntactic dependency parse."

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSentenceIteration() throws {
        let d = Doc(text: self.testSentence)
        
        for sent in d.sentences {
            for token in sent {
                print(token)
            }
        }
    }

    func testDoc() throws {
        let d = Doc(text: "The leftward immediate children of the word, in the syntactic dependency parse.")
        
        // test implicit string representation
        
    }
    
    func testLefts() throws {
        let d = Doc(text: self.testSentence)
        
        for left in d.sentences[0][4].lefts {
            print(left.text)
        }
    }
    
    func testRights() throws {
        let d = Doc(text: self.testSentence)
        
        var r = d.sentences[0][14].rights
        
        for right in r {
            print(right.text)
        }
    }
    
    func testSubtree() throws {
        let d = Doc(text: self.testSentence)
        
        
        for x in d.sentences[0][14].subtree {
            print(x.text)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
