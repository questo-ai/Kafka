//
//  RepresentationTests.swift
//  KafkaTests
//
//  Created by Khush Jammu on 2/5/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import XCTest
import CoreML
@testable import Kafka

class RepresentationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDoc() throws {
        let d = Doc(string: "Khush and Arya enjoy coding together.")
    }
    
    func testLefts() throws {
        let d = Doc(string: "Johnathon enjoys the occasional sampling of heroin.")
        for left in d.sentences[0].tokens[4].lefts {
            print(left.text)
        }
    }
    
    func testRights() throws {
        // TEST ON THIS TOO: Johanathon enjoys the occasional sampling of some heroin.
        let d = Doc(string: "Johnathon enjoys the occasional sampling of heroin.")
        for right in d.sentences[0].tokens[4].rights {
            print(right.text)
        }
    }
    
    func testSubtree() throws {
        let d = Doc(string: "Johnathon enjoys the occasional sampling of heroin.")
        for x in d.sentences[0].tokens[4].subtree {
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
