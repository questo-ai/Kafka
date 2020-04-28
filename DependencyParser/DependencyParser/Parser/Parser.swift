//
//  Parser.swift
//  DependencyParser
//
//  Created by Arya Vohra on 27/4/20.
//  Copyright © 2020 Questo. All rights reserved.
//

import UIKit
import NaturalLanguage

class Parser: NSObject {
    var model: DependencyParser!
    var tagger: NLTagger!
    
    override init() {
        self.model = DependencyParser()
        self.tagger = NLTagger(tagSchemes: [.lexicalClass])
    }
    
    func POSTag(sentence: String) -> [(String, String)] {
        var tags: [(String, String)] = []
        tagger.string = sentence
        let options: NLTagger.Options = [.omitWhitespace]
        //
        self.tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                tags.append((sentence.substring(with: tokenRange), tag.UPOS!))
            }
            return true
        }
        return tags
    }
    
    
    
    
}
