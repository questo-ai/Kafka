//
//  DependencyGraph.swift
//  DependencyParser
//
//  Created by Arya Vohra on 28/4/20.
//  Copyright © 2020 Questo. All rights reserved.
//

import UIKit

class DependencyGraph: NSObject {
    init(tree_str: String? = nil,
         cell_extractor: ((String, String, String) -> (Int, String, String, String, String, String, String, String))? = nil,
         zero_based: Bool = false,
         cell_separator: String? = nil,
        top_relation_label: String = "ROOT") {
        
        self.nodes = [
            "address": nil,
            "word": nil,
            "lemma": nil,
            "ctag": nil,
            "tag": nil,
            "feats": nil,
            "head": nil,
            "deps": nil
            "rel": nil,
        ]
    }
}
