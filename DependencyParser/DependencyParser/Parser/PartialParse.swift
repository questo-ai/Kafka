//
//  PartialParse.swift
//  DependencyParser
//
//  Created by Arya Vohra on 28/4/20.
//  Copyright © 2020 Questo. All rights reserved.
//

import UIKit
import NaturalLanguage

// ['acl', 'acl:relcl', 'advcl', 'advmod', 'amod', 'appos', 'aux', 'auxpass', 'case', 'cc', 'cc:preconj', 'ccomp', 'compound', 'compound:prt', 'conj', 'cop', 'csubj', 'csubjpass', 'dep', 'det', 'det:predet', 'discourse', 'dobj', 'expl', 'iobj', 'mark', 'mwe', 'neg', 'nmod', 'nmod:npmod', 'nmod:poss', 'nmod:tmod', 'nsubj', 'nsubjpass', 'nummod', 'parataxis', 'punct', 'root', 'xcomp']

enum ParserError: Error {
    case ValueError
}

class PartialParse: NSObject {
    private let left_arc_id = 0
    private let right_arc_id = 1
    private let shift_id = 2
    private let root_tag = "TOP"
    private var stack: [Int]
    private var next: Int
    private var arcs: [(Int, Int, String?)]
    private var sentence: [(String?, String)]
    
    
    init(sentence: [(String, String)]) {
        self.sentence = sentence
        self.sentence.insert((nil, self.root_tag), at: 0)
        self.stack = [0]
        self.next = 1
        self.arcs = []
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
            self.arcs.append((self.stack[-1], self.stack[-2], deprel))
            self.stack.remove(at: -2)
        } else if ((transition_id == self.right_arc_id) && (deprel != nil) && (self.stack.count >= 2)) {
            self.arcs.append((self.stack[-2], self.stack[-1], deprel))
            self.stack.remove(at: -1)
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
        } else {
            return Array(deps[0...(n!)])
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
        } else {
            return Array(deps[0...(n!)])
        }
    }
    
    func contains(a: [(Int, Int)], v: (Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a {if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    
    func get_oracle(graph: DependencyGraph) -> (Int, String) {
        if (self.complete) {
            fatalError("PartialParse already completed")
        }
        var transition_id = -1
        var deprel: String? = nil
        var left_deps = [(Int, Int, String?)]()
        var right_deps = [(Int, Int, String?)]()
        
        var arcs = [(Int, Int)]()
        for arc in self.arcs {
            arcs.append((arc.0, arc.1))
        }
        
        for (node_idx, node) in graph.nodes {
            for (rel, deps) in node.deps! {
                for dep in deps {
                    if (!self.contains(a: arcs, v: (node_idx, dep))) {
                        if (node_idx > dep) {
                            left_deps.append((node_idx, dep, rel))
                        } else {
                            right_deps.append((node_idx, dep, rel))
                        }
                    }
                }
            }
        }
        
        var nodes = [Int]()
        for triplets in right_deps {
            nodes.append(triplets.0)
        }
        
        for (node_idx, dep, rel) in right_deps.sorted(by: { $0.0 == $1.0 ? $0.1 < $1.1 : $0.0 < $1.0  }) {
            if (self.stack.contains(node_idx) && self.stack.contains(dep) && !nodes.contains(dep)) {
                transition_id = self.right_arc_id
                deprel = rel
                break
            }
        }

        for (node_idx, dep, rel) in left_deps.sorted(by: { $0.0 == $1.0 ? -$0.1 < -$1.1 : $0.0 < $1.0  }) {
            if (self.stack.contains(node_idx) && self.stack.contains(dep)) {
                transition_id = self.left_arc_id
                deprel = rel
                break
            }
        }
        
        if (transition_id == -1) {
            transition_id = self.shift_id
        }
            
        return (transition_id, deprel!)
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
