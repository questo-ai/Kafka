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
            let array2 = try MLMultiArray(shape: [1,18], dataType: .float32)
            let array3 = try MLMultiArray(shape: [1,12], dataType: .float32)
            let output = try model.prediction(Placeholder: array1, Placeholder_1: array2, Placeholder_2: array3)
            return output.output_td_vec
        } catch  {
            print(error)
            return nil
        }
    }
    
    
    
    
}
