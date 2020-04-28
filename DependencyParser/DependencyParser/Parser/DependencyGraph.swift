//
//  DependencyGraph.swift
//  DependencyParser
//
//  Created by Arya Vohra on 28/4/20.
//  Copyright © 2020 Questo. All rights reserved.
//

import UIKit

struct Node {
    var address: Int? = nil
    var word: String? = nil
    var lemma: String? = nil
    var ctag: String? = nil
    var tag: String? = nil
    var feats: String? = nil
    var head: String? = nil
    var deps: [String: [Int]]? = nil
    var rel: String? = nil
    
    init(address: Int? = nil, word: String? = nil, lemma: String? = nil, ctag: String? = nil, tag: String? = nil, feats: String? = nil, head: String? = nil, deps: [String: [Int]]? = nil, rel: String? = nil) {
        self.address = address
        self.word = word
        self.lemma = lemma
        self.ctag = ctag
        self.tag = tag
        self.feats = feats
        self.head = head
        self.deps = deps
        self.rel = rel
    }
}

class DependencyGraph: NSObject {
    var root: Node?
    var nodes = [Int: Node]()
    
    init(tree_str: String? = nil,
         cell_extractor: ((String, String, String) -> (Int, String, String, String, String, String, String, String))? = nil,
         zero_based: Bool = false,
         cell_separator: String? = nil,
        top_relation_label: String = "ROOT") {
        
        self.nodes[0] = Node(address: 0, ctag: "TOP", tag: "TOP")
        if ((tree_str) != nil) {
            
        }
    }
    
    
    func remove_by_address(address: Int) {
        self.nodes.removeValue(forKey: address)
    }
    
    
    func redirect_arcs(originals: [Int: [Node]], redirect: [Int: [Node]]) {
    }
    
    
}
