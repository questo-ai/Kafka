//
//  POSTagger.swift
//  Kafka
//
//  Copyright © 2020 Questo AI. All rights reserved.
//

import NaturalLanguage

open class POSTagger {
    var tagger: NLTagger!
    
    init() {
        self.tagger = NLTagger(tagSchemes: [.lexicalClass])
    }

    func tag(sentence: String) -> [(String, String)] {
        var tags: [(String, String)] = []
        self.tagger.string = sentence
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
}
