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
    
    var lefts: [Token] {
        var leftsTemp: [Token] = []
        for position in (self.lEdge...self.index) {
            if (self.sent.tokens[position].head.index == self.index) {
                leftsTemp.append(self.sent.tokens[position])
            }
        }
        return leftsTemp
    }
    var lKids = 0
    var lEdge: Int
    
    var rights: [Token] {
        var rightsTemp: [Token] = []
        
        var s = self.subtree
        for x in s {print(x.text + "," +  String(x.headIndex))}
        print(s)
        
        
        for token in subtree.reversed() {
            if token.index == self.index {
                break
            }
            
            if token.headIndex == self.index {
                rightsTemp.append(token)
            }
        }
        
//        for position in stride(from: self.rEdge, through: self.index, by: -1) {
//            print(position)
//            if (self.sent.tokens[position].head.index == self.index) {
//                rightsTemp.append(self.sent.tokens[position])
//            }
//        }
        return rightsTemp.reversed()
    }
    var rKids = 0
    var rEdge: Int
    
    var subtree: [Token] {
        return Array(self.sent.tokens[self.lEdge...self.rEdge])
    }
    
    var pos: String
    var dep: String
    var sentiment: Float?
    
    init(offset: Int, doc: Doc, sent: Sentence, token: String, headIndex: Int, pos: String, dep: String, sentiment: Float?) {
        self.index = offset
        self.doc = doc
        self.sent = sent
        self.text = token
        if (headIndex == -1) {
            self.headIndex = offset
        } else {
            self.headIndex = headIndex
        }
        self.pos = pos
        self.dep = dep
        self.sentiment = sentiment
        self.lEdge = index
        self.rEdge = index
    }
}
