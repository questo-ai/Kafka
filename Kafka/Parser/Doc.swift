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
    open var sentences: [String]?
    open var arcs: [[(Int, Int, String?)]]?
    private var tagger: NLTagger!
    
    init(sentenceLists: [String]?) {
        self.tagger = NLTagger(tagSchemes: [.lexicalClass])
        self.sentences = sentenceLists
    }
    
    convenience init(string: String) {
        var sentences: [String]?
        let sentenceTokenizer = NLTokenizer(unit: .sentence)
        sentenceTokenizer.string = string
        sentenceTokenizer.enumerateTokens(in: string.startIndex..<string.endIndex) { tokenRange, _ in
            let sentence = String(string[tokenRange])
            sentences?.append(sentence)
            return true
        }
        self.init(sentenceLists: sentences)
    }
    
    private func POSTag(sentence: String) -> [(String, String)] {
        var tags: [(String, String)] = []
        tagger.string = sentence
        let options: NLTagger.Options = [.omitWhitespace]
        //
        self.tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                tags.append((String(sentence[tokenRange]), tag.UPOS!))
            }
            return true
        }
        return tags
    }
    
    func taggedSentences() -> [[(String, String)]]{
        var taggedSentences = [[(String, String)]]()
        for sentence in (sentences ?? []) {
            taggedSentences.append(self.POSTag(sentence: sentence))
        }
        return taggedSentences
    }
}
