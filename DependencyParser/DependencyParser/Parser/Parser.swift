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
    var model: DependencyParser!
    var tagger: NLTagger!
    
    override init() {
        self.model = DependencyParser()
        self.tagger = NLTagger(tagSchemes: [.lexicalClass])
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
    
    
    func predict(sentence: String) -> MLMultiArray?{
        do {
            let array1 = try MLMultiArray(shape: [1,18], dataType: .float32)
            let array_1 = [0, 4002, 4002, 1087, 2360, 4001, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002, 4002]
            for (i, x) in array_1.enumerated() {
                array1[i] = NSNumber(floatLiteral: Double(x))
            }
            
            let array2 = try MLMultiArray(shape: [1,18], dataType: .float32)
            let array_2 = [0, 19, 19, 11, 14, 12, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19]
            for (i, x) in array_2.enumerated() {
                array2[i] = NSNumber(floatLiteral: Double(x))
            }
            
            let array3 = try MLMultiArray(shape: [1,12], dataType: .float32)
            let array_3 = [41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41, 41]
            for (i, x) in array_3.enumerated() {
                array3[i] = NSNumber(floatLiteral: Double(x))
            }
            let output = try model.prediction(Placeholder: array1, Placeholder_1: array2, Placeholder_2: array3)
            return output.output_td_vec
        } catch  {
            print(error)
            return nil
        }
    }
}
