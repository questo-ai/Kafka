//
//  Doc.swift
//  Kafka
//
//  Copyright © 2020 Questo AI. All rights reserved.
//

import Foundation
import NaturalLanguage

open class Doc: CustomStringConvertible {
    open var sentences: [Sentence] = []
    open var arcs: [[(Int, Int, String?)]]?
    open var dependencyParser: DependencyParser!
    open var tagger: POSTagger!
    open var text: String
    
    public var description: String { return self.text }
    
    init(sentenceList: [String]) {
        self.tagger = POSTagger()
        self.dependencyParser = DependencyParser()
        var x: Sentence
        
        self.text = sentenceList.joined(separator: " ")
        
        for sentence in sentenceList {
            x = Sentence(sentence: sentence, tagger: self.tagger, dependencyParser: self.dependencyParser, doc: self)
            self.sentences.append(x)
        }
    }
    
    convenience init(text: String) {
        var sentences = [String]()
        let sentenceTokenizer = NLTokenizer(unit: .sentence)
        sentenceTokenizer.string = text
        sentenceTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let sentence = String(text[tokenRange])
            sentences.append(sentence)
            return true
        }
        self.init(sentenceList: sentences)
    }
}
