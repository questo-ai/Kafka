# PartialParse
This is the internal documentation for the `PartialParse` class. Wherever details are omitted, please refer to the original code. 

## Instance Variables

#### Constants
**`self.left_arc_id`**
Type: `Int`
_Value: `1`_
An identifier signifying a left arc transition. Used for internal parsing logic.

**`self.right_arc_id`**
Type: `Int`
_Value: `1`_
An identifier signifying a right arc transition. Used for internal parsing logic. 

**`self.shift_id`**
Type: `Int`
_Value: `2`_
An identifier signifying a shift transition. Used for internal parsing logic. 

**`self.root_tag`**
Type: `String`
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