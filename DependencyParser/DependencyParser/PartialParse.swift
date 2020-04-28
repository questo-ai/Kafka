//
//  PartialParse.swift
//  DependencyParser
//
//  Created by Taichi Kato on 28/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import Foundation
import UIKit
import NaturalLanguage

public class PartialParse: NSObject {

}

extension NLTag {
    var UPOS: String? {
        switch self {
        // Lexical classes
        case .adjective:
            return "ADJ"
        case .adverb:
            return "ADV"
        case .classifier:
            return "CLASSIFIER"
        case .conjunction:
            return "CONJ"
        case .determiner:
            return "DET"
        case .idiom:
            return "IDIOM"
        case .interjection:
            return "INTJ"
        case .noun:
            return "NOUN"
        case .number:
            return "NUM"
        case .particle:
            return "PART"
        case .preposition:
            return "PREP"
        case .pronoun:
            return "PRON"
        case .verb:
            return "VERB"
        // Punctuation
        case .punctuation:
            return "PUNCT"
        case .sentenceTerminator:
            return "PUNCT"
        case .openQuote:
            return "PUNCT"
        case .closeQuote:
            return "PUNCT"
        case .openParenthesis:
            return "PUNCT"
        case .closeParenthesis:
            return "PUNCT"
        case .wordJoiner:
            return "PUNCT"
        case .dash:
            return "PUNCT"
        case .otherPunctuation:
            return "PUNCT"
        default:
            return nil
        }
    }
}
