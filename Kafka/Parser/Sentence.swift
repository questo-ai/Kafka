//
//  Sentence.swift
//  Kafka
//
//  Created by Arya Vohra on 1/5/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import UIKit
import NaturalLanguage
//import CoreML

open class Sentence {
    var text: String
    var doc: Doc
    var tokens: [Token] = []
    var tagger: POSTagger
    var dependencyParser: DependencyParser!
    
    init(sentence: String, tagger: POSTagger, dependencyParser: DependencyParser, doc: Doc) {
        self.text = sentence
        self.doc = doc
        self.tagger = tagger
        self.dependencyParser = dependencyParser
        let tagged = self.tagger.tag(sentence: sentence)
        var tokens = [Token?](repeating: nil, count: tagged.count)
        let arcs = self.dependencyParser.predict(sentence: tagged)
        
        
        for arc in arcs {
            let textTagPair = tagged[arc.1-1]
            let token = Token(offset: arc.1-1, doc: doc, sent: self, token: textTagPair.0, headIndex: arc.0-1, pos: textTagPair.1, dep: arc.2!, sentiment: nil)
            tokens[arc.1-1] = token
        }
        
        for token in tokens {
            self.tokens.append(token!)
        }
    }
}
