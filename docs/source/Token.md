# Token
This is the internal documentation for the `Token` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables
### Mutable

**`self.text`**
Type: `String`
Holds text of the given token.

**`self.index`**
Type: `Int`
Holds position of token in parent sentence. 

**`self.doc`**
Type: `Doc`
Holds reference to parent `Doc` object. 

**`self.sentence`**
Type: `Sentence`
Holds reference to parent `Sentence` object. 

**`self.headIndex`**
Type: `Int`
Holds index of head token in parent sentence.

**`self.head`**
Type: `Token`
Holds head token. 

**`self.lKids`**
Type: `Int`
Holds number of left children tokens. 

**`self.lEdge`**
Type: `Int`
Holds index of left-most token relative to current token. 

**`self.rKids`**
Type: `Int`
Holds number of right children tokens. 

**`self.rEdge`**
Type: `Int`
Holds index of right-most token relative to current token. 

**`self.pos`**
Type: `String`
Holds POS tag.

**`self.dep`**
Type: `String`
Holds dependency relation tag.

### Properties
**`self.isSentStart`**
Type: `Bool`
Returns true if is first token in sentence, false otherwise.

**`self.lefts`**
Type: `[Token]`
Returns all tokens to the left of current token in syntax tree. 

**`self.rights`**
Type: `[Token]`
Returns all tokens to the right of current token in syntax tree. 

**`self.subtree`**
Type: `[Token]`
Returns subtree of current token. 

## `init(offset: Int, doc: Doc, sent: Sentence, token: String, headIndex: Int, pos: String, dep: String, sentiment: Float?)`

**Arguments**
This function takes the values for all its instance variables as arguments. 

**Purpose**
Initializes the `Token` object. Note that `headIndex` is not necessarily the value passed in the constructor: refer to the code for details. 

**Returns**
None.
