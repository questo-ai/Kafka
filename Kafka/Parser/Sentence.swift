//
//  Sentence.swift
//  Kafka
//
//  Created by Arya Vohra on 1/5/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import UIKit

open class Sentence {
    var text: String
    var tokens: [Token]
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    convenience init(text: String) {
        self.text = text
        
        let tokens = POSTag(sentence: text)
        self.init(tokens)
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
