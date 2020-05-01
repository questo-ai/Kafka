//
//  Parser.swift
//  DependencyParser
//
//  Created by Taichi Kato on 28/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import NaturalLanguage
import CoreML

public class Parser {
    var model = DependencyParser()
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
                tags.append((String(sentence[tokenRange]), tag.UPOS!))
            }
            return true
        }
        return tags
    }
    
    
    func _predict(_ wordIDs: MLMultiArray, _ tagIDs: MLMultiArray, _ deprelIDs: MLMultiArray) -> (Int, String?) {
        do {
            let output = try model.prediction(Placeholder: wordIDs, Placeholder_1: tagIDs, Placeholder_2: deprelIDs)
            return self.transducer.tdVec2transDeprel(tdVec: output.output_td_vec)
        } catch  {
            print(error)
            return (-1, nil)
        }
    }
    
    
    func predict(sentences: [[(String, String)]]) ->  [[(Int, Int, String?)]] {
        var arcs = [[(Int, Int, String?)]]()
        // Uses an object wrapper to reference same array
        var pps = PartialParses()
        for sentence in sentences {
            let pp = PartialParse(sentence: sentence)
            while !pp.complete {
                let feats = transducer.pp2feat(partial: pp)
                let td_pair = _predict(feats.0, feats.1, feats.2)
                pp.parse_step(transition_id: td_pair.0, deprel: td_pair.1)
            }
            pps.collection.append(pp)
        }
        for parse in pps.collection {
            arcs.append(parse.arcs)
        }
        return arcs
    }
    
    func predictOnSentences(sentences: [String]) -> [[(Int, Int, String?)]] {
        var taggedSentences = [[(String, String)]]()
        for sentence in sentences {
            taggedSentences.append(self.POSTag(sentence: sentence))
        }
        return self.predict(sentences: taggedSentences)
    }
}

struct PartialParses {
    var collection = [PartialParse]()
}
