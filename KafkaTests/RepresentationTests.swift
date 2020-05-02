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
        let d = Doc(sentenceList: ["In an Oct. 19 review of \"The Misanthrope\" at Chicago's Goodman Theatre (\"Revitalized Classics Take the Stage in Windy City,\" Leisure & Arts), the role of Celimene, played by Kim Cattrall, was mistakenly attributed to Christina Haag."])
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
