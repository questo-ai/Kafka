//
//  Doc.swift
//  Kafka
//
//  Created by Taichi Kato on 1/5/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import Foundation
import NaturalLanguage

open class Doc {
    open var sentences: [Sentence]?
    open var arcs: [[(Int, Int, String?)]]?
    open var dependencyParser: DependencyParser!
    open var tagger: POSTagger!
    
    
    init(sentenceList: [String]) {
        self.tagger = POSTagger()
        self.dependencyParser = DependencyParser()
        for sentence in sentenceList {
            self.sentences!.append(Sentence(sentence: sentence, tagger: self.tagger, dependencyParser: self.dependencyParser, doc: self))
        }
    }
    
    
    convenience init(string: String) {
        var sentences = [String]()
        let sentenceTokenizer = NLTokenizer(unit: .sentence)
        sentenceTokenizer.string = string
        sentenceTokenizer.enumerateTokens(in: string.startIndex..<string.endIndex) { tokenRange, _ in
            let sentence = String(string[tokenRange])
            sentences.append(sentence)
            return true
        }
        self.init(sentenceList: sentences)
    }
}
