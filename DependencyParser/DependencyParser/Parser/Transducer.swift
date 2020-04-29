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
    
    func convertArrayToML(array: [Int]) -> MLMultiArray {
        do {
            let mlArray =  try MLMultiArray(shape: [1,NSNumber(value: array.count)], dataType: .float32)
            for (i, x) in array.enumerated() {
                mlArray[i] = NSNumber(floatLiteral: Double(x))
            }
            return mlArray
        } catch {
            fatalError()
        }
    }
    
    func pp2feat(partial: PartialParse) -> (MLMultiArray,MLMultiArray,MLMultiArray){
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
        var wordIDs = [Int](repeating: self.nullWordId, count: 18)
        var tagIDs = [Int](repeating: self.nullTagId, count: 18)
        var deprelIDs = [Int](repeating: self.nullDeprelId, count: 12)
        
        for stackIdx in 0...min(3, partial.stack.count) {
            let sentenceIdx = partial.stack[-1 - stackIdx] // test crashed on this line 
            var (word, tag) = partial.sentence[sentenceIdx]
            wordIDs[stackIdx] = self.word2id[word!, default: self.unkWordId]
            tagIDs[stackIdx] = self.tag2id[tag, default: self.unkTagId]
            if stackIdx == 2 {
                continue
            }
            
            for (leftIdx, leftDep) in partial.get_n_leftmost_deps(sentence_idx: sentenceIdx, n: 2).enumerated() {
                (word, tag) = partial.sentence[leftDep]
                
                var deprels = [String?]() // not quite sure how to implement next() functionality
                
                for arc in partial.arcs {
                    if (arc.1 == leftDep) {
                        deprels.append(arc.2)
                    }
                }
                
                wordIDs[6 + leftIdx + 2 * stackIdx] = self.word2id[word!, default: self.unkWordId]
                tagIDs[6 + leftIdx + 2 * stackIdx] = self.tag2id[tag, default: self.unkTagId]
                deprelIDs[leftIdx + 2 * stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]

                if (leftIdx != nil) { // this condition is probably wrong
                    for leftLeftDep in partial.get_n_leftmost_deps(sentence_idx: leftDep, n: 1) {
                        (word, tag) = partial.sentence[leftLeftDep]
                        deprels = []
                        for arc in partial.arcs {
                            if (arc.1 == leftLeftDep) {
                                deprels.append(arc.2)
                            }
                        }
                        wordIDs[14 + stackIdx] = self.word2id[word!, default: self.unkWordId]
                        tagIDs[14 + stackIdx] = self.tag2id[tag, default: self.unkTagId]
                        deprelIDs[8 + stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]
                    }
                }
            }
            
            for (rightIdx, rightDep) in partial.get_n_rightmost_deps(sentence_idx: sentenceIdx, n: 2).enumerated() {
                (word, tag) = partial.sentence[rightDep]
                
                var deprels = [String?]() // not quite sure how to implement next() functionality
                
                for arc in partial.arcs {
                    if (arc.1 == rightDep) {
                        deprels.append(arc.2)
                    }
                }
                
                wordIDs[10 + rightIdx + 2 * stackIdx] = self.word2id[word!, default: self.unkWordId]
                tagIDs[10 + rightIdx + 2 * stackIdx] = self.tag2id[tag, default: self.unkTagId]
                deprelIDs[4 + rightIdx + 2 * stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]

                if (rightIdx != nil) { // this condition is probably wrong
                    for rightRightDep in partial.get_n_rightmost_deps(sentence_idx: rightDep, n: 1) {
                        (word, tag) = partial.sentence[rightRightDep]
                        deprels = []
                        for arc in partial.arcs {
                            if (arc.1 == rightRightDep) {
                                deprels.append(arc.2)
                            }
                        }
                        wordIDs[16 + stackIdx] = self.word2id[word!, default: self.unkWordId]
                        tagIDs[16 + stackIdx] = self.tag2id[tag, default: self.unkTagId]
                        deprelIDs[10 + stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]
                    }
                }
            }
        }
        
        for (bufIdx, sentenceIdx) in (partial.next...min(partial.next+3, partial.sentence.count)).enumerated() {
            let (word, tag) = partial.sentence[bufIdx]
            wordIDs[3 + bufIdx] = self.word2id[word!, default: self.unkWordId]
            tagIDs[3 + bufIdx] = self.tag2id[tag, default: self.unkTagId]
        }
        
        return (self.convertArrayToML(array: wordIDs), self.convertArrayToML(array: tagIDs), self.convertArrayToML(array: deprelIDs))
    }
    
//    func td_vec2trans_deprel(td_vec: MLMultiArray) -> (Int, String) {
//        
//    }
}
