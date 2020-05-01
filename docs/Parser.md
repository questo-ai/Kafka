# Parser
This is the internal documentation for the `Parser` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables

**`self.model`**
Type: `DependencyParser`
Holds instance of `DependencyParser()`. 

**`self.tagger`**
Type: `NLTagger` (_strict_)
Assigned instance of `NLTagger` in `init()`.

**`self.transducer`**
Type: `Transducer` (_strict_)
Assigned instance of `Transducer` in `init()`.

## `init(wordList: [String], tagList: [String], deprelList: [String])`

**Arguments**
`wordList`: array of words in the wordlist as `String`. Mandatory. 
`tagList`: array of POS tags as `String`. Mandatory.
`deprelList`: array of dependency tags as `String`. Mandatory.

**Purpose**
Initialises the `Parser` object. Assigns a value to `self.tagger` and `self.transducer`.

**Returns**
Constructors return nothing.