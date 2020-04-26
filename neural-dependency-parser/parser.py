from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from itertools import chain
from nltk.parse import DependencyGraph


class PartialParse(object):
    '''A PartialParse is a snapshot of an arc-standard dependency parse

    It is fully defined by a quadruple (sentence, stack, next, arcs).

    sentence is a tuple of ordered pairs of (word, tag), where word
    is a a word string and tag is its part-of-speech tag.

    Index 0 of sentence refers to the special "root" node
    (None, self.root_tag). Index 1 of sentence refers to the sentence's
    first word, index 2 to the second, etc.

    stack is a list of indices referring to elements of
    sentence. The 0-th index of stack should be the bottom of the stack,
    the (-1)-th index is the top of the stack (the side to pop from).

    next is the next index that can be shifted from the buffer to the
    stack. When next == len(sentence), the buffer is empty.

    arcs is a list of triples (idx_head, idx_dep, deprel) signifying the
    dependency relation `idx_head ->_deprel idx_dep`, where idx_head is
    the index of the head word, idx_dep is the index of the dependant,
    and deprel is a string representing the dependency relation label.
    '''

    left_arc_id = 0
    '''An identifier signifying a left arc transition'''

    right_arc_id = 1
    '''An identifier signifying a right arc transition'''

    shift_id = 2
    '''An identifier signifying a shift transition'''

    root_tag = "TOP"
    '''A POS-tag given exclusively to the root'''

    def __init__(self, sentence):
        # the initial PartialParse of the arc-standard parse
        self.sentence = ((None, self.root_tag),) + tuple(sentence)
        self.stack = [0]
        self.next = 1
        self.arcs = []

    @property
    def complete(self):
        '''bool: return true iff the PartialParse is complete

        Assume that the PartialParse is valid
        '''
        return self.next == len(self.sentence) and len(self.stack) == 1

    def parse_step(self, transition_id, deprel=None):
        '''Update the PartialParse with a transition

        Args:
            transition_id : int
                One of left_arc_id, right_arc_id, or shift_id. You
                should check against `self.left_arc_id`,
                `self.right_arc_id`, and `self.shift_id` rather than
                against the values 0, 1, and 2 directly.
            deprel : str or None
                The dependency label to assign to an arc transition
                (either a left-arc or right-arc). Ignored if
                transition_id == shift_id

        Raises:
            ValueError if transition_id is an invalid id or is illegal
                given the current state
        '''
        if self.complete:
            raise ValueError()
        elif transition_id == self.left_arc_id and deprel and len(self.stack) >= 2:
            # create and add left arc dependency relation to arcs
            # then remove dependent from stack
            self.arcs.append((self.stack[-1], self.stack[-2], deprel))
            self.stack.pop(-2)
        elif transition_id == self.right_arc_id and deprel and len(self.stack) >= 2:
            # create and add right arc dependency relation to arcs
            # then remove dependent from stack
            self.arcs.append((self.stack[-2], self.stack[-1], deprel))
            self.stack.pop(-1)
        elif transition_id == self.shift_id and self.next < len(self.sentence):
            #  shift the next index in buffer to stack and increment next index
            self.stack.append(self.next)
            self.next += 1
        else:
            raise ValueError()

    def get_n_leftmost_deps(self, sentence_idx, n=None):
        '''Returns a list of n leftmost dependants of word

        Leftmost means closest to the beginning of the sentence.

        Note that only the direct dependants of the word on the stack
        are returned (i.e. no dependants of dependants).

        Args:
            sentence_idx : refers to word at self.sentence[sentence_idx]
            n : the number of dependants to return. "None" refers to all
                dependants

        Returns:
            deps : The n leftmost dependants as sentence indices.
                If fewer than n, return all dependants. Return in order
                with the leftmost @ 0, immediately right of leftmost @
                1, etc.
        '''
        deps = [dep[1] for dep in self.arcs if dep[0] == sentence_idx]
        deps.sort()
        return deps[:n]

    def get_n_rightmost_deps(self, sentence_idx, n=None):
        '''Returns a list of n rightmost dependants of word on the stack @ idx

        Rightmost means closest to the end of the sentence.

        Note that only the direct dependants of the word on the stack
        are returned (i.e. no dependants of dependants).

        Args:
            sentence_idx : refers to word at self.sentence[sentence_idx]
            n : the number of dependants to return. "None" refers to all
                dependants

        Returns:
            deps : The n rightmost dependants as sentence indices. If
                fewer than n, return all dependants. Return in order
                with the rightmost @ 0, immediately left of leftmost @
                1, etc.
        '''
        deps = [dep[1] for dep in self.arcs if dep[0] == sentence_idx]
        deps.sort(reverse=True)
        return deps[:n]

    def get_oracle(self, graph):
        '''Given a projective dependency graph, determine an appropriate trans

        This method chooses either a left-arc, right-arc, or shift so
        that, after repeated calls to pp.parse_step(*pp.get_oracle(graph)),
        the arc-transitions this object models matches the
        DependencyGraph "graph". For arcs, it also has to pick out the
        correct dependency relationship.

        Some relevant details about graph:
         - graph.nodes[i] corresponds to self.sentence[i]
         - graph.nodes[i]['head'] is either the i-th word's head word or
           None if i is the root word (i == 0)
         - graph.nodes[i]['deps'] returns a dictionary of arcs whose
           keys are dependency relationships and values are lists of
           indices of dependents. For example, given the list
           `dependents = graph.nodes[i]['deps']['det']`, the following
           arc transitions exist:
             self.sentences[i] ->_'det' self.sentences[dependents[0]]
             self.sentences[i] ->_'det' self.sentences[dependents[1]]
             ... (etc.)
         - graph is projective. Informally, this means no crossed lines
           in the dependency graph.
           More formally, if i -> j and j -> k, then:
             if i > j (left-ark), i > k
             if i < j (right-ark), i < k

        *IMPORTANT* if left-arc and shift operations are both valid and
        can lead to the same graph, always choose the left-arc
        operation.

        *ALSO IMPORTANT* make sure to use the values `self.left_arc_id`,
        `self.right_arc_id`, `self.shift_id` rather than 0, 1, and 2
        directly

        Hint: take a look at get_left_deps and get_right_deps below

        Args:
            graph : nltk.parse.dependencygraph.DependencyGraph
                A projective dependency graph to head towards

        Returns:
            transition_id, deprel : the next transition to take, along
                with the correct dependency relation label

        Raises:
            ValueError if already completed. Otherwise you can always
            assume that a valid move exists that heads towards the
            target graph
        '''
        if self.complete:
            raise ValueError('PartialParse already completed')
        transition_id, deprel = -1, None

        # list of all potential left and right dependent relations
        left_deps, right_deps = [], []

        # list of existing arcs
        arcs = [(arc[0], arc[1]) for arc in self.arcs]

        # iterate all nodes in graph and find all potential parse base on the
        # current stack configuration
        for node_idx in graph.nodes:
            node = graph.nodes[node_idx]

            for rel, deps in node['deps'].items():
                for dep in deps:
                    # add relation to list if the relation is not already in arcs
                    if (node_idx, dep) not in arcs:
                        if node_idx > dep:
                            left_deps.append((node_idx, dep, rel))
                        else:
                            right_deps.append((node_idx, dep, rel))

        # list of nodes that has right dependent
        nodes = [pairs[0] for pairs in right_deps]
        # iterate all possible right dependent relations, perform right arc if
        # the node and the dependent are in stack, and the dependent is not
        # that node of another dependent.
        for node, dep, rel in sorted(right_deps, key=lambda element: (element[0], element[1])):
            if node in self.stack and dep in self.stack and dep not in nodes:
                transition_id = self.right_arc_id
                deprel = rel
                break

        # iterate all possible left dependent relations, preform left arc if
        # the node and the dependent are in stack, the dependent that is
        # closer to the node has higher priority to ones that aew further away.
        # left arc has higher priority than right arc, thus even if a right
        # arc is found, left arc can still replace it
        for node, dep, rel in sorted(left_deps, key=lambda element: (element[0], -element[1])):
            if node in self.stack and dep in self.stack :
                transition_id = self.left_arc_id
                deprel = rel
                break

        # preform shift when no left or right arc
        if transition_id == -1:
            transition_id = self.shift_id

        return transition_id, deprel

    def parse(self, td_pairs):
        """Applies the provided transitions/deprels to this PartialParse

        Simply reapplies parse_step for every element in td_pairs

        Args:
            td_pairs:
                The list of (transition_id, deprel) pairs in the order
                they should be applied
        Returns:
            The list of arcs produced when parsing the sentence.
            Represented as a list of tuples where each tuple is of
            the form (head, dependent)
        """
        for transition_id, deprel in td_pairs:
            self.parse_step(transition_id, deprel)
        return self.arcs


def minibatch_parse(sentences, model, batch_size):
    """Parses a list of sentences in minibatches using a model.

    Note that parse_step may raise a ValueError if your model predicts
    an illegal (transition, label) pair. Remove any such `stuck`
    partial-parses from the list unfinished_parses.

    Args:
        sentences:
            A list of "sentences", where each element is itself a
            list of pairs of (word, pos)
        model:
            The model that makes parsing decisions. It is assumed to
            have a function model.predict(partial_parses) that takes in
            a list of PartialParse as input and returns a list of
            pairs of (transition_id, deprel) predicted for each parse.
            That is, after calling
                td_pairs = model.predict(partial_parses)
            td_pairs[i] will be the next transition/deprel pair to apply
            to partial_parses[i].
        batch_size:
            The number of PartialParse to include in each minibatch
    Returns:
        arcs:
            A list where each element is the arcs list for a parsed
            sentence. Ordering should be the same as in sentences (i.e.,
            arcs[i] should contain the arcs for sentences[i]).
    """

    arcs = []
    # initialize a PartialParser for each sentence
    partial_parses = [PartialParse(sentence) for sentence in sentences]
    # initialize a shallow copy of partial_parses
    unfinished_parses = [parser for parser in partial_parses]

    while unfinished_parses:
        minibatch = unfinished_parses[:batch_size]
        td_pairs = model.predict(minibatch)

        # parse sentence base on model prediction
        for i in range(len(minibatch)):
            parse = minibatch[i]
            error = False
            try:
                parse.parse_step(td_pairs[i][0], td_pairs[i][1])
            except ValueError:
                error = True
             # add parses that is completed or has error to list
            if parse.complete or error:
                unfinished_parses.pop(unfinished_parses.index(parse))

    for parse in partial_parses:
        arcs.append(parse.arcs)

    return arcs


def get_sentence_from_graph(graph, include_root=False):
    '''Get the associated sentence from a DependencyGraph'''
    sentence_w_addresses = [
        (node['address'], node['word'], node['ctag'])
        for node in graph.nodes.values()
        if include_root or node['word'] is not None
    ]
    sentence_w_addresses.sort()
    return tuple(t[1:] for t in sentence_w_addresses)


def get_deps(node):
    '''Get the indices of dependants of a node from a DependencyGraph'''
    return chain(*node['deps'].values())


def get_left_deps(node):
    '''Get the arc-left dependants of a node from a DependencyGraph'''
    # address == graph key
    return (dep for dep in get_deps(node) if dep < node['address'])


def get_right_deps(node):
    '''Get the arc-right dependants of a node from a DependencyGraph'''
    return (dep for dep in get_deps(node) if dep > node['address'])
