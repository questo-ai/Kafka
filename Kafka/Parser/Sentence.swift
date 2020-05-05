//
//  Sentence.swift
//  Kafka
//
//  Copyright © 2020 Questo AI. All rights reserved.
//

import NaturalLanguage

open class Sentence: CustomStringConvertible {
    var text: String
    var doc: Doc
    var tokens: [Token] = []
    var tagger: POSTagger!
    var dependencyParser: DependencyParser!
    var length: Int
    
    public var description: String { return self.text }
    
    init(sentence: String, tagger: POSTagger, dependencyParser: DependencyParser, doc: Doc) {
        self.text = sentence
        self.doc = doc
        self.tagger = tagger
        self.dependencyParser = dependencyParser
        let tagged = self.tagger.tag(sentence: sentence)
        var tokens = [Token?](repeating: nil, count: tagged.count)
        let arcs = self.dependencyParser.predict(sentence: tagged)
        self.length = tagged.count
        
        for arc in arcs {
            let textTagPair = tagged[arc.1-1]
            let token = Token(offset: arc.1-1, doc: doc, sent: self, token: textTagPair.0, headIndex: arc.0-1, pos: textTagPair.1, dep: arc.2!)
            tokens[arc.1-1] = token
        }
        
        for token in tokens {
            self.tokens.append(token!)
        }
        
        self.setLeftRightChildrenAndEdges()
    }
    
    func setLeftRightChildrenAndEdges() {
        var head: Token
        var child: Token
        
        for i in 0...self.length-1 {
            child = self.tokens[i]
            head = self.tokens[child.headIndex]
            if (child.index < head.index) {
                head.lKids += 1
            }
            if (child.lEdge < head.lEdge) {
                head.lEdge = child.lEdge
            }
            if (child.rEdge > head.rEdge) {
                head.rEdge = child.rEdge 
            }
        }
        
        for i in stride(from: self.length-1, to: 0, by: -1) {
            child = self.tokens[i]
            head = self.tokens[child.headIndex]
            if (child.index > head.index) {
                head.rKids += 1
            }
            if (child.rEdge > head.rEdge) {
                head.rEdge = child.rEdge
            }
            if (child.lEdge < head.lEdge) {
                head.lEdge = child.lEdge
            }
        }
    }
}

extension Sentence: Collection {
    public func index(after i: Int) -> Int {
        return self.tokens.index(after: i)
    }
    
    public var startIndex: Int {
        return self.tokens.startIndex
    }
    
    public var endIndex: Int {
        return self.tokens.endIndex
    }
    
    public typealias Element = Token
    public typealias Index = Int
    
    public subscript(position: Index) -> Element {
        return self.tokens[position]
    }
}
