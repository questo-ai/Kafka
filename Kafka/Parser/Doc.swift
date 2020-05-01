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
    private var tagger: NLTagger!
    
    
    init(sentenceLists: [Sentence]?) {
        self.tagger = NLTagger(tagSchemes: [.lexicalClass])
        self.sentences = sentenceLists
    }
    
    
    convenience init(string: String) {
        var sentences: [Sentence]?
        let sentenceTokenizer = NLTokenizer(unit: .sentence)
        sentenceTokenizer.string = string
        sentenceTokenizer.enumerateTokens(in: string.startIndex..<string.endIndex) { tokenRange, _ in
            let sentence = Sentence(text: String(string[tokenRange]))
            sentences?.append(sentence)
            return true
        }
        self.init(sentenceLists: sentences)
    }
}
