//
//  Parser.swift
//  DependencyParser
//
//  Created by Taichi Kato on 28/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import UIKit
import NaturalLanguage
import CoreML

public class Parser: NSObject {
    static var model = DependencyParser()
    var tagger: NLTagger!
    var transducer: Transducer!
    
    init(wordList: [String?], tagList: [String], deprelList: [String]) {
        self.tagger = NLTagger(tagSchemes: [.lexicalClass])
        self.transducer = Transducer(wordList: wordList, tagList: tagList, deprelList: deprelList)
    }
    
    func POSTag(sentence: String) -> [(String, String)] {
        var tags: [(String, String)] = []
        tagger.string = sentence
        let options: NLTagger.Options = [.omitWhitespace]
        //
        self.tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                tags.append((sentence.substring(with: tokenRange), tag.UPOS!))
            }
            return true
        }
        return tags
    }
    
    
    static func predict(wordIDs: MLMultiArray, tagIDs: MLMultiArray, deprelIDs: MLMultiArray) -> MLMultiArray?{
        do {
            let output = try model.prediction(Placeholder: wordIDs, Placeholder_1: tagIDs, Placeholder_2: deprelIDs)
            return output.output_td_vec
//                self.transducer.td_vec2trans_deprel(td_vec: output.output_td_vec)
        } catch  {
            print(error)
            return nil
        }
    }
}
