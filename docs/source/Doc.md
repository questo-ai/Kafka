# Doc
This is the internal documentation for the `Doc` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables
### Mutable

**`self.sentences`**
Type: `[Sentence]`
Holds array of `Sentence` objects. 

**`self.dependencyParser`**
Type: `DependencyParser` (_strict_)
Holds instance of `DependencyParser()`.

**`self.tagger`**
Type: `POSTagger` (_strict_)
Holds instance of `POSTagger()`.

**`self.text`**
Type: `String`
Holds the actual text of the document.


## `init(sentenceList: [String])`

**Arguments**
`sentenceList`: array of sentences as `String`. Mandatory. 

**Purpose**
Initializes the `Doc` object by performing POS tagging and dependency parsing, storing it in our custom `Sentence` and `Token` classes. 

**Returns**
None.

**Additional Notes**
Overloaded function. 


## `init(text: String)`

**Arguments**
`text`: a single `String` containing all the sentences for the `Doc`. Mandatory. 

**Purpose**
Initializes the `Doc` object by performing POS tagging and dependency parsing, storing it in our custom `Sentence` and `Token` classes. Internally, it tokenizes `text` into a list of sentences, then calls `self.init(sentenceList: sentences)`.

**Returns**
None.

**Additional Notes**
Overloaded function. 