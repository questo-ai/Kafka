# PartialParse
This is the internal documentation for the `PartialParse` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables

#### Constants
**`self.left_arc_id`**
Type: `Int` (static)
_Value: `1`_
An identifier signifying a left arc transition. Used for internal parsing logic. 

**`self.right_arc_id`**
Type: `Int` (static)
_Value: `1`_
An identifier signifying a right arc transition. Used for internal parsing logic. 

**`self.shift_id`**
Type: `Int` (static)
_Value: `2`_
An identifier signifying a shift transition. Used for internal parsing logic. 

**`self.root_tag`**
Type: `String` (static)
_Value: `"TOP"`_
A POS-tag given exclusively to the root. Used for internal parsing logic. 

#### Mutable
**`self.stack`**
Type: `[Int]`
An array of indices referring to elements of sentence. Used for internal parsing logic. 

**`self.next`**
Type: `Int`
The next index that can be shifted from the buffer to the stack. Used for internal parsing logic. 

**`self.arcs`**
Type: `[(Int, Int, String?)]`
A list of triples `(idx_head, idx_dep, deprel)` signifying the dependency relation `idx_head ->_deprel idx_dep`, where idx_head is the index of the head word, idx_dep is the index of the dependant, and deprel is a string representing the dependency relation label.

**`self.sentence`**
Type: `[(String?, String)]`
An array of tuples of ordered pairs of `(word, tag)`, where tag is the POS tag for the corresponding word in the sentence. 

**`self.complete`**
Type: `Bool`
True IFF the `PartialParse` is complete. Assumes that `PartialParse` is valid. 


## `init(sentence: [(String, String)])`

**Arguments**
`sentence`: ordered array of pairs `(word, tag)`, where `tag` is the POS tag for the corresponding word in the sentence. Stored in `self.sentence`, with a `root_tag` inserted at the beginning. 

**Purpose**
Initialize instance variables with the appropriate values. 

**Returns**
None.

## `parse_step(transition_id: Int, deprel: String?)`

**Arguments**
`transition_id`: an `Int` representing a type of transition (_`left_arc_id`_, _`right_arc_id`_, or _`shift_id`_).
`deprel`: the dependency label to assign the dependency transition. Ignored if _`transition_id == shift_id`_.

**Purpose**
Updates the `PartialParse` object with a given transition.

**Returns**
None.


## `get_n_leftmost_deps(sentence_idx: Int, n: Int?) -> [Int]`

**Arguments**
`sentence_idx`: an `Int` referring to the word at _`self.sentence[sentence_idx]`_.
`n`: the number of dependents to return as an `Int`. If `nil`, return all. 

**Purpose**
Returns a list of `n` leftmost dependants of word. Leftmost means closest to the beginning of the sentence. Note that only the direct dependants of the word on the stack are returned (i.e. no dependants of dependants).

**Returns**
An array of integers that correspond to words in `self.sentence`.

## `get_n_rightmost_deps(sentence_idx: Int, n: Int?) -> [Int]`

**Arguments**
`sentence_idx`: an `Int` referring to the word at _`self.sentence[sentence_idx]`_.
`n`: the number of dependents to return as an `Int`. If `nil`, return all. 

**Purpose**
Returns a list of `n` rightmost dependants of word. Rightmost means closest to the end of the sentence. Note that only the direct dependants of the word on the stack are returned (i.e. no dependants of dependants).

**Returns**
Returns a list of `n` rightmost dependants of word, as an array of integers that refer to words in _`self.sentence`_. 

## `parse(td_pairs: [(Int, String)]) -> [(Int, Int, String?)]`

**Arguments**
`td_pairs`: list of _`(transition_id, deprel)`_ pairs in the order they should be applied.

**Purpose**
Applies the provided transitions/dependency relations to the `PartialParse`. Simply reapplies `parse_step` for every element in `td_pairs`.

**Returns**
Returns `self.arcs`.