# DependencyParser
This is the internal documentation for the `DependencyParser` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables

**`self.model`**
Type: `DependencyParser`
Holds instance of `DependencyParser()`. 

**`self.transducer`**
Type: `Transducer` (_strict_)
Holds instance of `Transducer()`.

## `predict(_ wordIDs: MLMultiArray, _ tagIDs: MLMultiArray, _ deprelIDs: MLMultiArray) -> (Int, String?)`

**Arguments**
`wordIDs`: list of word IDs (position in a wordlist) as `MLMultiArray`. Mandatory. 
`tagIDs`: list of tag IDs (position in a list of tags) as `MLMultiArray`. Mandatory.
`deprelIDs`: list of dependency IDs (position in a list of dependency) as `MLMultiArray`. Mandatory.

**Purpose**
Performs a prediction using the CoreML model and returns the raw `trans/deprel` pairs. 

**Returns**
Type: `[[Int, Int, String?]]`
Returns array of arrays, each corresponding to the arcs for a given sentence. Each sub-array contains tuples with three elements — the first is the index of the head (relative to the sentence), the second is the index of the dependent (relative to the sentence), and the third is the dependency itself. 

**Additional Notes**
Overloaded function. 


## `predict(sentences: [[(String, String)]]) ->  [[(Int, Int, String?)]]`

**Arguments**
`sentences`: array of sentences, where each sentence is represented as an array of `(word,pos)` tuples. Mandatory.

**Purpose**
Performs prediction using the CoreML model, uses it to perform the dependency parsing, and returns an array of dependency relations for each sentence given. 

**Returns**
Type: `[[Int, Int, String?]]`
Returns array of arrays, each corresponding to the arcs for a given sentence. Each sub-array contains tuples with three elements — the first is the index of the head (relative to the sentence), the second is the index of the word (relative to the sentence) related to the head, and the third is the dependency itself. 

**Additional Notes**
Overloaded function. 


## `predict(text: Doc) -> Doc`

**Arguments**
`text`: a `Doc` object that contains the text to be parsed using the dependency parser. 

**Purpose**
Performs prediction using the CoreML model, uses it to perform the dependency parsing, and returns an array of dependency relations for each sentence given. 

**Returns**
Type: `Doc`
Returns `Doc` object passed received from argument, with the arcs added to the appropriate instance variable. 

**Additional Notes**
Overloaded function. 
