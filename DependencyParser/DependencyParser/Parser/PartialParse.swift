//
//  PartialParse.swift
//  DependencyParser
//
//  Created by Arya Vohra on 28/4/20.
//  Copyright © 2020 Questo. All rights reserved.
//

import NaturalLanguage

enum ParserError: Error {
    case ValueError
}

class PartialParse: NSObject {
    public let left_arc_id = 0
    public let right_arc_id = 1
    public let shift_id = 2
    public let root_tag = "TOP"
    public var stack: [Int]
    public var next: Int
    public var arcs: [(Int, Int, String?)]
    public var sentence: [(String?, String)]
    
    
    init(sentence: [(String, String)]) {
        self.sentence = sentence
        self.sentence.insert((nil, self.root_tag), at: 0)
        self.stack = [0]
        self.next = 1
        self.arcs = []
    }
    
    func removed_by_address() {
        
    }
    
    var complete: Bool {
        get {
            return (self.next == self.sentence.count) && (self.stack.count == 1)
        }
    }
    
    
    func parse_step(transition_id: Int, deprel: String?) {
        if (self.complete) {
            fatalError("ValueError")
        } else if ((transition_id == self.left_arc_id) && (deprel != nil) && (self.stack.count >= 2)) {
            self.arcs.append((self.stack[self.stack.count-1], self.stack[self.stack.count-2], deprel))
            self.stack.remove(at: self.stack.count-2)
        } else if ((transition_id == self.right_arc_id) && (deprel != nil) && (self.stack.count >= 2)) {
            self.arcs.append((self.stack[self.stack.count-2], self.stack[self.stack.count-1], deprel))
            self.stack.remove(at: self.stack.count-1)
        } else if ((transition_id == self.shift_id) && (self.next < self.sentence.count)) {
            self.stack.append(self.next)
            self.next += 1
        } else {
            fatalError("ValueError")
        }
    }
    
    
    func get_n_leftmost_deps(sentence_idx: Int, n: Int?) -> [Int] {
        var deps: [Int] = []
        for dep in self.arcs {
            if (dep.0 == sentence_idx) {
                deps.append(dep.1)
            }
        }
        deps.sort()
        if (n == nil) {
            return deps
        } else if (deps.count < n!) {
            return deps
        } else {
            if deps.isEmpty {
                return deps
            } else {
                return Array(deps[0...(n!-1)])
            }
        }
    }
    
    
    func get_n_rightmost_deps(sentence_idx: Int, n: Int?) -> [Int] {
        var deps: [Int] = []
        for dep in self.arcs {
            if (dep.0 == sentence_idx) {
                deps.append(dep.1)
            }
        }
        deps.sort(by: >)
        if (n == nil) {
            return deps
        } else if (deps.count < n!) {
            return deps
        } else {
            if deps.isEmpty {
                return deps
            } else {
                return Array(deps[0...(n!-1)])
            }
        }
    }
    
    func contains(a: [(Int, Int)], v: (Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a {if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    func parse(td_pairs: [(Int, String)]) -> [(Int, Int, String?)] {
        for (transition_id, deprel) in td_pairs {
            self.parse_step(transition_id: transition_id, deprel: deprel)
        }
        return self.arcs
    }
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
            return nil
        case .conjunction:
            return "CONJ"
        case .determiner:
            return "DET"
        case .idiom:
            return nil
        case .interjection:
            return "INTJ"
        case .noun:
            return "NOUN"
        case .number:
            return "NUM"
        case .otherWord:
            return "X"
        case .particle:
            return "PART"
        case .preposition:
            return "ADP"
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
