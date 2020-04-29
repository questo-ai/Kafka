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
    
    init(treeStr: String? = nil,
         cellExtractor: ((String, String, String) -> (Int, String, String, String, String, String, String, String))? = nil,
         zeroBased: Bool = false,
         cellSeparator: CharacterSet? = nil,
        top_relation_label: String = "ROOT") {
        
        self.nodes[0] = Node(address: 0, ctag: "TOP", tag: "TOP")
        if ((treeStr) != nil) {
            
        }
    }
    func remove_by_address(address: Int) {
        self.nodes.removeValue(forKey: address)
    }
    
    func redirect_arcs(originals: [Int: [Node]], redirect: [Int: [Node]]) {
//        Redirects arcs to any of the nodes in the originals list
//        to the redirect node address.
//        for node in self.nodes.values():
//            new_deps = []
//            for dep in node["deps"]:
//                if dep in originals:
//                    new_deps.append(redirect)
//                else:
//                    new_deps.append(dep)
//            node["deps"] = new_deps
        for node in nodes.values {
            let new_deps = [Node]()
            if let deps = node.deps?.enumerated(){
                for dep in deps{
//                    if dep in originals{
//                        
//                    }
                }
            }
        }

    }
    
    func add_arc(head_address: Int, mod_address: Int) {
//        Adds an arc from the node specified by head_address to the
//        node specified by the mod address.
    }
    
    func connect_graph() {
//       Fully connects all non-root nodes.  All nodes are set to be dependents
//       of the root node.
    }
    func get_by_address(node_address: Int){
    }
    func contains_address(node_address: Int){
    }
    func left_children(node_index: Int){
        // Returns the number of left children under the node specified
        // by the given address.
    }
    func right_children(node_index: Int){
        // Returns the number of right children under the node specified
        // by the given address.
    }
    func add_node(node: Node){

    }
    func _word(node: Node, filter: Bool = true){

    }
    func _tree(i: Int){
        // Turn dependency graphs into NLTK trees.
        // :param int i: index of a node
        // :return: either a word (if the indexed node is a leaf) or a ``Tree``.
    }
    func tree(){
        // Starting with the ``root`` node, build a dependency tree using the NLTK
        // ``Tree`` constructor. Dependency labels are omitted.
    }
    func triples(node: Node){
        // Extract dependency triples of the form:
        // ((head word, head tag), rel, (dep word, dep tag))
    }
    func _hd(i: Int){


    }
    func _rel(i: Int){
    }
    func contains_cycle(){
        
        //Check whether there are cycles.

        // >>> dg = DependencyGraph(treebank_data)
        // >>> dg.contains_cycle()
        // False

        // >>> cyclic_dg = DependencyGraph()
        // >>> top = {'word': None, 'deps': [1], 'rel': 'TOP', 'address': 0}
        // >>> child1 = {'word': None, 'deps': [2], 'rel': 'NTOP', 'address': 1}
        // >>> child2 = {'word': None, 'deps': [4], 'rel': 'NTOP', 'address': 2}
        // >>> child3 = {'word': None, 'deps': [1], 'rel': 'NTOP', 'address': 3}
        // >>> child4 = {'word': None, 'deps': [3], 'rel': 'NTOP', 'address': 4}
        // >>> cyclic_dg.nodes = {
        // ...     0: top,
        // ...     1: child1,
        // ...     2: child2,
        // ...     3: child3,
        // ...     4: child4,
        // ... }
        // >>> cyclic_dg.root = top

        // >>> cyclic_dg.contains_cycle()
        // [3, 1, 2, 4]

    }
    func get_cycle_path(curr_node: Node, goal_node_index: Int){
    }
    
//    func _parse(input_: String,
//                cell_extractor: ((String, String, String) -> (Int, String, String, String, String, String, String, String))? = nil,
//                zeroBased: Bool = false,
//                cellSeparator: CharacterSet? = nil,
//                top_relation_label: String = "ROOT") {
//        
//        func extract_3_cells(cells: (String, String, String), index: Int) -> (Int, String, String, String, String, String, String, String) {
//            let word = cells.0
//            let tag = cells.1
//            let head = cells.2
//            return (index, word, word, tag, tag, "", head, "")
//        }
//        
//        func extract_4_cells(cells: (String, String, String, String), index: Int) -> (Int, String, String, String, String, String, String, String) {
//            let word = cells.0
//            let tag = cells.1
//            let head = cells.2
//            let rel = cells.3
//            return (index, word, word, tag, tag, "", head, rel)
//        }
//        
//        func extract_7_cells(cells: (String, String, String, String, String, String, String), index: Int) -> (Int, String, String, String, String, String, String, String) {
//            var castIndex = index
//            let line_index = cells.0
//            let word = cells.1
//            let lemma = cells.2
//            let tag = cells.3
//            let head = cells.5
//            let rel = cells.6
//            
//            if (Int(line_index) != nil) {
//                castIndex = Int(line_index)!
//            }
//            
//            return (castIndex, word, lemma, tag, tag, "", head, rel)
//        }
//        
//        func extract_10_cells(cells: (String, String, String, String, String, String, String, String, String, String), index: Int) -> (Int, String, String, String, String, String, String, String) {
//            var castIndex = index
//            let line_index = cells.0
//            let word = cells.1
//            let lemma = cells.2
//            let ctag = cells.3
//            let tag = cells.4
//            let feats = cells.5
//            let head = cells.6
//            let rel = cells.7
//            
//            if (Int(line_index) != nil) {
//                castIndex = Int(line_index)!
//            }
//            
//            return (castIndex, word, lemma, ctag, tag, feats, head, rel)
//        }
//        
//        let extractors = [
//            3: extract_3_cells,
//            4: extract_4_cells,
//            7: extract_7_cells,
//            10: extract_10_cells,
//            ] as [Int : Any]
//        
//        var inputLines = [String]()
//        
//        if (type(of: input_) == String.self) {
//            var inputLines = [String]()
//            for line in input_.split(separator: "\n") {
//                inputLines.append(String(line))
//            }
//        } else {
//            inputLines = [input_]
//        }
//        
//        var cellNumber: Int? = nil
//        for (index, line) in inputLines.enumerated() {
//            var cells = line.components(separatedBy: cellSeparator!)
//            
//            if (cellNumber == nil) {
//                cellNumber = cells.count
//            } else {
//                assert(cellNumber == cells.count)
//            }
//            
//            var cellExtractor: (([String], Int) -> (String, String, String, String, String, String, String, String))
//            if (cellSeparator == nil) {
//                do {
//                    let cellExtractor = extractors[cellNumber!]
//                } catch {
//                    fatalError("Number of tab-delimited fields" + String(cellNumber!) + " not supported by CoNLL(10) or Malt-Tab(4) format")
//                }
//            }
//            
//            do {
//                let (index, word, lemma, ctag, tag, feats, head, rel) = cellExtractor(cells, index)
//            } catch {
//                let (word, lemma, ctag, tag, feats, head, rel) = cellExtractor(cells, index)
//            }
//        }
//        
//    }
    
    
}
