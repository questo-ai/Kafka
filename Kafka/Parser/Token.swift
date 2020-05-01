//
//  Token.swift
//  Kafka
//
//  Created by Arya Vohra on 1/5/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import UIKit

open class Token {
    var text: String
    var textWithWs: String
    var whitespace: String // maybe Char
    var index: Int
    var isSentStart: Bool {
        if (self.index == 0) {
            return true
        } else {
            return false
        }
    }
    var doc: Doc
//    var sent: Sentence // not implemented
    var head: Token
    var lefts: [Token] {
        
    }
    var rights: [Token] {
        
    }
    var pos: String
    var dep: String
    var sentiment: Float
    
    init(offset: Int, doc: Doc, token: String, arc: (Int, Int, String?)) {
        self.index = offset
        self.doc = doc
        self.text = token
        
    }
}
