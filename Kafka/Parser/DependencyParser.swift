//
//  Parser.swift
//  DependencyParser
//
//  Created by Taichi Kato on 28/4/20.
//  Copyright © 2020 Questo AI. All rights reserved.
//

import NaturalLanguage
import CoreML

open class DependencyParser {
    private var model = DependencyParserModel()
    private var transducer: Transducer!
    
    init() {
        self.transducer = Transducer(wordList: Data.wordList, tagList: Data.tagList, deprelList: Data.deprelList)
    }

    
    
    internal func predict(_ wordIDs: MLMultiArray, _ tagIDs: MLMultiArray, _ deprelIDs: MLMultiArray) -> (Int, String?) {
        do {
            let output = try model.prediction(Placeholder: wordIDs, Placeholder_1: tagIDs, Placeholder_2: deprelIDs)
            return self.transducer.tdVec2transDeprel(tdVec: output.output_td_vec)
        } catch  {
            print(error)
            return (-1, nil)
        }
    }
    
    
    internal func predict(sentences: [[(String, String)]]) ->  [[(Int, Int, String?)]] {
        var arcs = [[(Int, Int, String?)]]()
        // Uses an object wrapper to reference same array
        var pps = PartialParses()
        for sentence in sentences {
            let pp = PartialParse(sentence: sentence)
            while !pp.complete {
                let feats = transducer.pp2feat(partial: pp)
                let td_pair = predict(feats.0, feats.1, feats.2)
                pp.parse_step(transition_id: td_pair.0, deprel: td_pair.1)
            }
            pps.collection.append(pp)
        }
        for parse in pps.collection {
            arcs.append(parse.arcs)
        }
        return arcs
    }
    public func predict(text: Doc) -> Doc{
        let arcs = self.predict(sentences: text.taggedSentences())
        text.arcs = arcs
        return text
    }
}

struct PartialParses {
    var collection = [PartialParse]()
}
