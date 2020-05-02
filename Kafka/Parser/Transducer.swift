//
//  Transducer.swift
//  DependencyParser
//
//  Created by Arya Vohra on 29/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import CoreML

class Transducer: NSObject {
    let rootWord: String? = nil
    let unkWord = "_"
    let rootTag = "TOP"
    let unkTag = "_"
    let rootDeprel = "ROOT"
    let unkDeprel = "_"
    
    var id2word = [String?]()
    var id2tag = [String?]()
    var id2deprel = [String?]()
    var word2id = [String: Int]()
    var tag2id = [String: Int]()
    var deprel2id = [String: Int]()
    
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
        self.id2deprel = deprelList
        self.id2deprel.insert(self.rootDeprel, at: 0)
        self.id2deprel.append(self.unkDeprel)
        for (index, value) in self.id2word.enumerated() {
            self.word2id[value ?? "NIL_WORD"] = index
        }
        for (index, value) in self.id2tag.enumerated() {
            self.tag2id[value ?? "NIL_WORD"] = index
        }
        for (index, value) in self.id2deprel.enumerated() {
            self.deprel2id[value ?? "NIL_WORD"] = index
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
        var wordIDs = [Int](repeating: self.nullWordId, count: 18)
        var tagIDs = [Int](repeating: self.nullTagId, count: 18)
        var deprelIDs = [Int](repeating: self.nullDeprelId, count: 12)
        
        for stackIdx in 0...(min(3, partial.stack.count)-1) {
            let stackReversed = partial.stack.reversed() as [Int]
            let sentenceIdx = stackReversed[stackIdx]
            var (word, tag) = partial.sentence[sentenceIdx]
            wordIDs[stackIdx] = self.word2id[word ?? "NIL_WORD", default: self.unkWordId]
            tagIDs[stackIdx] = self.tag2id[tag, default: self.unkTagId]
            if stackIdx == 2 {
                continue
            }
            
            for (leftIdx, leftDep) in partial.get_n_leftmost_deps(sentence_idx: sentenceIdx, n: 2).enumerated() {
                (word, tag) = partial.sentence[leftDep]
                
                var deprels = [String?]()
                
                for arc in partial.arcs {
                    if (arc.1 == leftDep) {
                        deprels.append(arc.2)
                    }
                }
                
                wordIDs[6 + leftIdx + 2 * stackIdx] = self.word2id[word ?? "NIL_WORD", default: self.unkWordId]
                tagIDs[6 + leftIdx + 2 * stackIdx] = self.tag2id[tag, default: self.unkTagId]
                deprelIDs[leftIdx + 2 * stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]

                if (leftIdx != 0) {
                    for leftLeftDep in partial.get_n_leftmost_deps(sentence_idx: leftDep, n: 1) {
                        (word, tag) = partial.sentence[leftLeftDep]
                        deprels = []
                        for arc in partial.arcs {
                            if (arc.1 == leftLeftDep) {
                                deprels.append(arc.2)
                            }
                        }
                        wordIDs[14 + stackIdx] = self.word2id[word ?? "NIL_WORD", default: self.unkWordId]
                        tagIDs[14 + stackIdx] = self.tag2id[tag, default: self.unkTagId]
                        deprelIDs[8 + stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]
                    }
                }
            }
            
            for (rightIdx, rightDep) in partial.get_n_rightmost_deps(sentence_idx: sentenceIdx, n: 2).enumerated() {
                (word, tag) = partial.sentence[rightDep]
                
                var deprels = [String?]()
                
                for arc in partial.arcs {
                    if (arc.1 == rightDep) {
                        deprels.append(arc.2)
                    }
                }
                
                wordIDs[10 + rightIdx + 2 * stackIdx] = self.word2id[word ?? "NIL_WORD", default: self.unkWordId]
                tagIDs[10 + rightIdx + 2 * stackIdx] = self.tag2id[tag, default: self.unkTagId]
                deprelIDs[4 + rightIdx + 2 * stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]

                if (rightIdx != 0) {
                    for rightRightDep in partial.get_n_rightmost_deps(sentence_idx: rightDep, n: 1) {
                        (word, tag) = partial.sentence[rightRightDep]
                        deprels = []
                        for arc in partial.arcs {
                            if (arc.1 == rightRightDep) {
                                deprels.append(arc.2)
                            }
                        }
                        wordIDs[16 + stackIdx] = self.word2id[word ?? "NIL_WORD", default: self.unkWordId]
                        tagIDs[16 + stackIdx] = self.tag2id[tag, default: self.unkTagId]
                        deprelIDs[10 + stackIdx] = self.deprel2id[deprels[0]!, default: self.unkDeprelId]
                    }
                }
            }
        }
        
        
        if (partial.next != min(partial.next+3, partial.sentence.count)) {
            for (bufIdx, sentenceIdx) in (partial.next...(min(partial.next+3, partial.sentence.count)-1)).enumerated() {
                let (word, tag) = partial.sentence[sentenceIdx]
                wordIDs[3 + bufIdx] = self.word2id[word ?? "NIL_WORD", default: self.unkWordId]
                tagIDs[3 + bufIdx] = self.tag2id[tag, default: self.unkTagId]
            }
        }
        
        return (self.convertArrayToML(array: wordIDs), self.convertArrayToML(array: tagIDs), self.convertArrayToML(array: deprelIDs))
    }
    
    func tdVec2transDeprel(tdVec: MLMultiArray) -> (Int, String?) {
        // note that this code assumes there is always a dependency, i.e. there isn't any case for handling when has_deprel is false
        let maxIdx = Math.argmax32(tdVec).0
        if maxIdx == 0 {
            return (PartialParse.shift_id, nil)
        } else if maxIdx <= id2deprel.count {
            return (PartialParse.left_arc_id, id2deprel[maxIdx - 1])
        } else {
            return (PartialParse.right_arc_id, id2deprel[maxIdx - id2deprel.count - 1])
        }
    }
}
