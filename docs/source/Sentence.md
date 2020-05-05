# Sentence
This is the internal documentation for the `Sentence` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables
### Mutable

**`self.text`**
Type: `String`
Holds text of the given sentence.

**`self.doc`**
Type: `Doc`
Holds reference to parent `Doc` object. 

**`self.tokens`**
Type: `[Token]`
Holds array of tokens for the given sentence. 

**`self.tagger`**
Type: `POSTagger` (_strict_)
Holds instance of `POSTagger()`.

**`self.dependencyParser`**
Type: `DependencyParser` (_strict_)
Holds instance of `DependencyParser()`.

**`self.length`**
Type: `Int`
Holds the number of tokens in the sentence (includes punctuation).


## `init(sentence: String, tagger: POSTagger, dependencyParser: DependencyParser, doc: Doc)`

**Arguments**
`sentence`: text of the sentence as a `String`. Mandatory. 

`tagger`: instance of `POSTagger` passed from `Doc`. Mandatory.

`dependencyParser`: instance of `DependencyParser` passed from `Doc`. Mandatory.

`doc`: instance of parent `Doc`. Mandatory

**Purpose**
Initializes the `Sentence` object.

**Returns**
None.


## `setLeftRightChildrenAndEdges()`

**Arguments**
None.

**Purpose**
Sets the `lEdge`, `lKids`, `rEdge`, and `rKids` properties for all the children tokens. Called in the constructor.

**Returns**
None.

## `extension Sentence: Collection`

This extension and the function definitions within allow you to iterate over the tokens in a `Sentence`. See below for an example. 

	let d = Doc(text: self.testSentence)
    let first_sentence = d.sentences[0]
    
    for token in first_sentence {
	    print(token)
    }    
