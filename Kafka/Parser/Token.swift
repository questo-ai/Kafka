//
//  Token.swift
//  Kafka
//
//  Copyright © 2020 Questo AI. All rights reserved.
//

open class Token: CustomStringConvertible {
    var text: String

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
    var head: Token { return self.sent[self.headIndex] }
    
    var lefts: [Token] {
        var leftsTemp: [Token] = []
        for position in (self.lEdge...self.index) {
            if (self.sent[position].head.index == self.index) {
                leftsTemp.append(self.sent[position])
            }
        }
        return leftsTemp
    }
    var lKids = 0
    var lEdge: Int
    
    var rights: [Token] {
        var rightsTemp: [Token] = []
        
        for position in stride(from: self.rEdge, through: self.index, by: -1) {
            if (self.sent[position].head.index == self.index) {
                rightsTemp.append(self.sent[position])
            }
        }
        
        return rightsTemp.reversed()
    }
    
    var rKids = 0
    var rEdge: Int
    
    var subtree: [Token] {
        return Array(self.sent[self.lEdge...self.rEdge])
    }
    
    var pos: String
    var dep: String
    
    public var description: String { return self.text }
    
    init(offset: Int, doc: Doc, sent: Sentence, token: String, headIndex: Int, pos: String, dep: String) {
        self.index = offset
        self.doc = doc
        self.sent = sent
        self.text = token
        self.pos = pos
        self.dep = dep
        self.lEdge = index
        self.rEdge = index
        
        // if token is root, make its head point to itself. else, point to head
        if (headIndex == -1) {
            self.headIndex = offset
        } else {
            self.headIndex = headIndex
        }
    }
}
