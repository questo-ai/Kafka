//
//  Transducer.swift
//  DependencyParser
//
//  Created by Arya Vohra on 29/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import UIKit
import CoreML

class Transducer: NSObject {
    var id2word = [String?]()
    var id2tag = [String?]()
    var id2deprel = [String?]()
    var word2id = [String: Int]()
    var tag2id = [String: Int]()
    var deprel2id = [String: Int]()
    
    var rootWord: String?
    var unkWord = "_"
    var rootTag = "TOP"
    var unkTag = "_"
    var rootDeprel = "ROOT"
    var unkDeprel = "_"
    
    var unkWordId: Int
    var unkTagId: Int
    var unkDeprelId: Int
    var nullWordId: Int
    var nullTagId: Int
    var nullDeprelId: Int
    
    init(wordList: [String?], tagList: [String], deprelList: [String]) {
        self.id2word = wordList
        self.id2word.insert(self.rootWord, at: 0)
        self.id2word.append(self.unkWord)
        self.id2tag = tagList
        self.id2tag.insert(self.rootTag, at: 0)
        self.id2tag.append(self.unkTag)
        self.id2deprel = tagList
        self.id2deprel.insert(self.rootDeprel, at: 0)
        self.id2deprel.append(self.unkDeprel)
        for (index, value) in self.id2tag.enumerated() {
            self.word2id[value!] = index
        }
        for (index, value) in self.id2tag.enumerated() {
            self.tag2id[value!] = index
        }
        for (index, value) in self.id2deprel.enumerated() {
            self.deprel2id[value!] = index
        }
        self.unkWordId = self.id2word.count - 1
        self.unkTagId = self.id2tag.count - 1
        self.unkDeprelId = self.id2deprel.count - 1
        self.nullWordId = self.id2word.count
        self.nullTagId = self.id2tag.count
        self.nullDeprelId = self.id2deprel.count
    
    }
    
    func pp2features(partial: PartialParse) -> (MLMultiArray,MLMultiArray,MLMultiArray){
//        word/tag vectors (18 each):
//            - top 3 ids on stack
//            - top 3 ids on buffer
//            - 1st and 2nd leftmost and rightmost dependants from top
//              two words on stack (8)
//            - leftmost-leftmost and rightmost-rightmost of top two words
//              on stack (4)
//
//        deprel vector (12):
//            - 1st and 2nd leftmost and rightmost dependants from top
//              two words on stack (8)
//            - leftmost-leftmost and rightmost-rightmost of top two words
//              on stack (4)
        
    }
    
    func td_vec2trans_deprel(td_vec: MLMultiArray) -> (Int, String) {
        
    }
}
