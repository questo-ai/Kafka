# DependencyParser
This is the internal documentation for the `DependencyParser` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables

**`self.model`**
Type: `DependencyParser`
Holds instance of `DependencyParser()`. 

**`self.transducer`**
Type: `Transducer` (_strict_)
Holds instance of `Transducer` in `init()`.

## `predict(_ wordIDs: MLMultiArray, _ tagIDs: MLMultiArray, _ deprelIDs: MLMultiArray) -> (Int, String?)`

**Arguments**
`wordIDs`: array of word IDs (position in a wordlist) as `MLMultiArray`. Mandatory. 
`tagIDs`: array of tag IDs (position in a list of tags) as `MLMultiArray`. Mandatory.
`deprelIDs`: array of dependency IDs (position in a list of dependency) as `MLMultiArray`. Mandatory.

**Purpose**
Initialises the `Parser` object. Assigns a value to `self.tagger` and `self.transducer`.

**Returns**
Type: `[[Int, Int, String?]]`
Returns array of arrays, each corresponding to the arcs for a given sentence. Each sub-array contains tuples with three elements — the first is the index of the head (relative to the sentence), the second is the index of the word (relative to the sentence) related to the head, and the third is the dependency itself. 