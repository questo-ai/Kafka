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
//    var textWithWs: String // not implemented
//    var whitespace: String // maybe Char
    var index: Int
    var isSentStart: Bool {
        if (self.index == 0) {
            return true
        } else {
            return false
        }
    }
    var doc: Doc
    var sent: Sentence
    var headIndex: Int
    var head: Token {
        return self.sent.tokens[self.headIndex]
    }
//    var lefts: [Token] {
//
//    }
//    var rights: [Token] {
//
//    }
    var pos: String
    var dep: String
    var sentiment: Float?
    
    init(offset: Int, doc: Doc, sent: Sentence, token: String, headIndex: Int, pos: String, dep: String, sentiment: Float?) {
        self.index = offset
        self.doc = doc
        self.sent = sent
        self.text = token
        self.headIndex = headIndex
        self.pos = pos
        self.dep = dep
        self.sentiment = sentiment
    }
}
