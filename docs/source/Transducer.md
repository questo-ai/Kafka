# Transducer
This is the internal documentation for the `Transducer` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables

#### Constants
**`self.rootWord`**
Type: `String?`
_Value: `nil`_
Placeholder for root word.

**`self.unkWord`**
Type: `String`
_Value: `_`_
Placeholder for unknown word.

**`self.rootTag`**
Type: `String`
_Value: `TOP`_
POS tag assigned to root node.

**`self.unkTag`**
Type: `String`
_Value: `_`_
POS tag assigned to unknown word. 

**`self.rootDeprel`**
Type: `String`
_Value: `ROOT`_
Dependency tag between root node and head word.

**`self.unkDeprel`**
Type: `String`
_Value: `_`_
Dependency tag for unknown relation. 

#### Mutable

**`self.id2word`**
Type: `[String?]` 
Wordlist as an array, plus the unknown and root word. Position of word corresponds to its ID. 

**`self.id2tag`**
Type: `[String?]`
POS tags as an array, plus the tag for unknown and root word. Position of tag corresponds to its ID.

**`self.id2deprel`**
Type: `[String?]` 
Dependency tags as an array, plus the tag for unknown and root word. Position of tag corresponds to its ID.

**`self.word2id`**
Type: `[String: Int]` 
Dictionary used to translate between words and their corresponding IDs. 

**`self.tag2id`**
Type: `[String: Int]` 
Dictionary used to translate between POS tags and their corresponding IDs. 

**`self.deprel2id`**
Type: `[String: Int]` 
Dictionary used to translate between dependency tags and their corresponding IDs. 


**`self.unkWordId`**
Type: `Int`
Word ID for an unknown word. 

**`self.unkTagId`**
Type: `Int`
POS tag ID for an unknown word.

**`self.unkDeprelId`**
Type: `Int`
Dependency tag ID for an unknown word.

**`self.nullWordId`**
Type: `Int`
Word ID that denotes null. 

**`self.nullTagId`**
Type: `Int`
POS tag ID that denotes null. 

**`self.nullDeprelId`**
Type: `Int`
Dependency tag ID that denotes null.

## `init(wordList: [String?], tagList: [String], deprelList: [String])`

**Arguments**
`wordList`: wordlist as an array of `String`.
`tagList`: list of POS tags as an array of `String`.
`deprelList`: list of dependency tags as an array of `String`.

**Purpose**
Initialize instance variables with the appropriate values. 

**Returns**
None.

## `convertArrayToML(array: [Int]) -> MLMultiArray`

**Arguments**
`array`: the array of `Int` to convert .

**Purpose**
Converts an array of `Int` into the CoreML-compatible `MLMultiArray`.

**Returns**
Returns the converted array as `MLMultiArray`.

## `pp2feat(partial: PartialParse) -> (MLMultiArray,MLMultiArray,MLMultiArray)`

**Arguments**
`partial`: the `PartialParse` object from which to construct a feature vector triple. 

**Purpose**
Constructs a feature vector triple `(word, pos, deprel)` from a `PartialParse` object. 

**Returns**
Returns `(word, pos, deprel)`, all of which are of type `MLMultiArray`. 

The following two paragraphs will be difficult to make sense of without first understanding the paper our dependency parser comes from.

The `word` and `tag` vectors have 18 values each for a single sentence. They are: top 3 ids on stack, top 3 ids on buffer, 1st and 2nd leftmost and rightmost dependants from top two words on stack (8), and leftmost-leftmost and rightmost-rightmost of top two words on stack (4).

The `deprel` vector has 12 values for a single sentence. They are: 1st and 2nd leftmost and rightmost dependants from top two words on stack (8), and the leftmost-leftmost and rightmost-rightmost of top two words on stack (4).

## `tdVec2transDeprel(tdVec: MLMultiArray) -> (Int, String?)`

**Arguments**
`partial`: the `trans/deprel` vector to translate, as an `MLMultiarray`.

**Purpose**
Converts a `trans/deprel` vector into a `trans,deprel` pair.

**Returns**
Returns `(transition_id, deprel)`.
