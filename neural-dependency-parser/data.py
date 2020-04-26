"""Handling the input and output of the Neural Dependency Model"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

from gzip import open as gz_open
from itertools import islice
from os.path import abspath
from os.path import dirname
from pickle import load
from sys import stdout

import numpy as np

from nltk.corpus.reader.api import SyntaxCorpusReader
from nltk.corpus.reader.util import read_blankline_block
from nltk.corpus.util import LazyCorpusLoader
from nltk.data import path
from nltk.parse import DependencyGraph

from parser import PartialParse
from parser import get_sentence_from_graph

class UniversalDependencyCorpusReader(SyntaxCorpusReader):
    '''Update to DependencyCorpusReader to account for 10-field conllu fmt'''

    def _read_block(self, stream):
        sent_block = read_blankline_block(stream)
        if not sent_block:
            return sent_block
        lines_w_comments = sent_block[0].split('\n')
        lines_wo_comments = (
            line.strip() for line in lines_w_comments
            if line and line[0] != '#'
        )
        field_block = (line.split('\t') for line in lines_wo_comments)
        # need to kill lines that represent contractions. Their first
        # field is a range (e.g. 1-2)
        field_block = (
            fields for fields in field_block if '-' not in fields[0])
        # "blocks" are lists of sentences, so return our generator
        # encapsulated
        return [field_block]

    def _word(self, s):
        return [fields[1] for fields in s]

    def _tag(self, s, _):
        return [(fields[1], fields[3]) for fields in s]

    def _parse(self, s):
        # dependencygraph wants it all back together...
        block = '\n'.join('\t'.join(line) for line in s)
        return DependencyGraph(block, top_relation_label='root')

path.append(abspath(dirname(__file__)))

ud_english = LazyCorpusLoader(
    'ud_english', UniversalDependencyCorpusReader, r'.*\.conll')

mystery = LazyCorpusLoader(
    'mystery', UniversalDependencyCorpusReader, r'.*\.conll')

class Transducer(object):
    """Provides generator methods for converting between data types

    Args:
        word_list : an ordered list of words in the corpus. word_list[i]
            will be assigned the id = i + 1. root is assigned id 0 and
            any words not in the list are assigned id = len(word_list) + 2.
            id = len(word_list) + 3 is assigned to invalid
        tag_list : an ordered list of part-of-speech tags in the corpus.
            ids assigned as with word_list
        deprel_list : an ordered list of dendency relations. ids
            assigned as with word_list
    """

    root_word = None
    '''Placeholder for the root word'''

    unk_word = '_'
    '''Placeholder for unknown words'''

    root_tag = 'TOP'
    '''POS tag assigned to root node'''

    unk_tag = '_'
    '''POS tag assigned to unknown words'''

    root_deprel = 'ROOT'
    '''Dependency relation btw root node and head word'''

    unk_deprel = '_'
    '''Unknown dependency relation'''

    def __init__(self, word_list, tag_list, deprel_list):
        self.id2word = (self.root_word,) + tuple(word_list)
        self.id2word += (self.unk_word,)
        self.id2tag = (self.root_tag,) + tuple(tag_list)
        self.id2tag += (self.unk_tag,)
        self.id2deprel = (self.root_deprel,) + tuple(deprel_list)
        self.id2deprel += (self.unk_deprel,)
        self.word2id = dict((val, idx) for idx, val in enumerate(self.id2word))
        self.tag2id = dict((val, idx) for idx, val in enumerate(self.id2tag))
        self.deprel2id = dict(
            (val, idx) for idx, val in enumerate(self.id2deprel))
        self.unk_word_id = len(self.id2word) - 1
        self.unk_tag_id = len(self.id2tag) - 1
        self.unk_deprel_id = len(self.id2deprel) - 1
        self.null_word_id = len(self.id2word)
        self.null_tag_id = len(self.id2tag)
        self.null_deprel_id = len(self.id2deprel)

    def graph2id(self, graph):
        '''Generate ID quads (word, tag, head, deprel) from single graph'''
        yield 0, 0, self.null_word_id, self.null_deprel_id
        for node_address in range(1, len(graph.nodes)):
            node = graph.nodes[node_address]
            yield (
                self.word2id.get(node['word'], self.unk_word_id),
                self.tag2id.get(node['ctag'], self.unk_tag_id),
                self.word2id.get(
                    graph.nodes[node['head']]['word'], self.unk_word_id),
                self.deprel2id.get(node['rel'], self.unk_deprel_id),
            )

    def graph2arc(self, graph, include_deprel=True):
        '''Generate (head_idx, dep_idx, deprel_id) tuples from single graph

        Args:
            include_deprel : whether to include the dependency label
        '''
        for node_address in range(1, len(graph.nodes)):
            node = graph.nodes[node_address]
            if include_deprel:
                yield (
                    node['head'], node_address,
                    self.deprel2id.get(node['rel'], self.unk_deprel_id),
                )
            else:
                yield (node['head'], node_address)

    def pp2feat(self, pp):
        '''From a PartialParse, construct a feature vector triple

        The triple can be fed in as word, pos, and deprel inputs to the
        transducer, respectively. They are formed as follows:

        word/tag vectors (18 each):
            - top 3 ids on stack
            - top 3 ids on buffer
            - 1st and 2nd leftmost and rightmost dependants from top
              two words on stack (8)
            - leftmost-leftmost and rightmost-rightmost of top two words
              on stack (4)

        deprel vector (12):
            - 1st and 2nd leftmost and rightmost dependants from top
              two words on stack (8)
            - leftmost-leftmost and rightmost-rightmost of top two words
              on stack (4)

        Returns:
            word_ids, tag_ids, deprel_ids
        '''
        word_ids = np.ones(18, dtype=np.int32) * self.null_word_id
        tag_ids = np.ones(18, dtype=np.int32) * self.null_tag_id
        deprel_ids = np.ones(12, dtype=np.int32) * self.null_deprel_id
        for stack_idx in range(min(3, len(pp.stack))):
            sentence_idx = pp.stack[-1 - stack_idx]
            word, tag = pp.sentence[sentence_idx]
            word_ids[stack_idx] = self.word2id.get(word, self.unk_word_id)
            tag_ids[stack_idx] = self.tag2id.get(tag, self.unk_tag_id)
            if stack_idx == 2:
                continue
            # first 2 leftmost
            for l_idx, l_dep in enumerate(
                    pp.get_n_leftmost_deps(sentence_idx, n=2)):
                word, tag = pp.sentence[l_dep]
                # should only be one that matches this
                deprel = next(arc[2] for arc in pp.arcs if arc[1] == l_dep)
                word_ids[6 + l_idx + 2 * stack_idx] = self.word2id.get(
                    word, self.unk_word_id)
                tag_ids[6 + l_idx + 2 * stack_idx] = self.tag2id.get(
                    tag, self.unk_tag_id)
                deprel_ids[l_idx + 2 * stack_idx] = self.deprel2id.get(
                    deprel, self.unk_deprel_id)
                if not l_idx: # leftmost-leftmost
                    for ll_dep in pp.get_n_leftmost_deps(l_dep, n=1):
                        word, tag = pp.sentence[ll_dep]
                        deprel = next(
                            arc[2] for arc in pp.arcs if arc[1] == ll_dep)
                        word_ids[14 + stack_idx] = self.word2id.get(
                            word, self.unk_word_id)
                        tag_ids[14 + stack_idx] = self.tag2id.get(
                            tag, self.unk_tag_id)
                        deprel_ids[8 + stack_idx] = self.deprel2id.get(
                            deprel, self.unk_deprel_id)
            # first 2 rightmost
            for r_idx, r_dep in enumerate(
                    pp.get_n_rightmost_deps(sentence_idx, n=2)):
                word, tag = pp.sentence[r_dep]
                deprel = next(arc[2] for arc in pp.arcs if arc[1] == r_dep)
                word_ids[10 + r_idx + 2 * stack_idx] = self.word2id.get(
                    word, self.unk_word_id)
                tag_ids[10 + r_idx + 2 * stack_idx] = self.tag2id.get(
                    tag, self.unk_tag_id)
                deprel_ids[4 + r_idx + 2 * stack_idx] = self.deprel2id.get(
                    deprel, self.unk_deprel_id)
                if not r_idx: # rightmost-rightmost
                    for rr_dep in pp.get_n_rightmost_deps(r_dep, n=1):
                        word, tag = pp.sentence[rr_dep]
                        deprel = next(
                            arc[2] for arc in pp.arcs if arc[1] == rr_dep)
                        word_ids[16 + stack_idx] = self.word2id.get(
                            word, self.unk_word_id)
                        tag_ids[16 + stack_idx] = self.tag2id.get(
                            tag, self.unk_tag_id)
                        deprel_ids[10 + stack_idx] = self.deprel2id.get(
                            deprel, self.unk_deprel_id)
        for buf_idx, sentence_idx in enumerate(
                range(pp.next, min(pp.next + 3, len(pp.sentence)))):
            word, tag = pp.sentence[sentence_idx]
            word_ids[buf_idx + 3] = self.word2id.get(word, self.unk_word_id)
            tag_ids[buf_idx + 3] = self.tag2id.get(tag, self.unk_tag_id)
        return word_ids, tag_ids, deprel_ids

    def pps2feats(self, pps):
        '''Partial parses to feature vector triples'''
        feats = (self.pp2feat(pp) for pp in pps)
        return zip(*feats)

    def graphs2feats_and_tds(self, graphs):
        '''From graphs, construct feature vector triples and trans,dep vecs

        Intended for training. This method takes in gold-standard
        dependency trees and yields pairs of (feat_vec, td_vec),
        where feat_vec are feature vectors as described in pp2feat, and
        td_vec is a (2 * len(self.id2deprel) + 1)-long
        float32 vector that encodes the transition operation as follows:

         - index 0 encodes the shift op
         - indices 1 to len(self.id2deprel) + 1 incl. encode the
           left-arc with dependency relations, excluding the "null"
           deprel
         - incides len(self.id2deprel) + 1 to
           2 * len(self.id2deprel) + 1  encode the right-arc with
           dependency relations, excluding the "null" deprel

        It uses PartialParses' get_oracle method to determine the
        arc standard form. If a graph is non-projective, this generator
        will skip the instance.
        '''
        for graph in graphs:
            pp = PartialParse(get_sentence_from_graph(graph))
            td_vecs = []
            feat_tups = []
            try:
                while not pp.complete:
                    transition_id, deprel = pp.get_oracle(graph)
                    td_vec = np.zeros(
                        2 * len(self.id2deprel) + 1, dtype=np.float32)
                    if transition_id == pp.shift_id:
                        td_vec[0] = 1.
                    else:
                        deprel_id = self.deprel2id.get(
                            deprel, self.unk_deprel_id)
                        if transition_id == pp.left_arc_id:
                            td_vec[1 + deprel_id] = 1.
                        else:
                            td_vec[1 + len(self.id2deprel) + deprel_id] = 1.
                    td_vecs.append(td_vec)
                    feat_tups.append(self.pp2feat(pp))
                    pp.parse_step(transition_id, deprel)
            except (ValueError, IndexError):
                # no parses. If PartialParse is working, this occurs
                # when the graph is non-projective. Skip the instance
                continue
            for feat_tup, td_vec in zip(feat_tups, td_vecs):
                yield feat_tup, td_vec

    def remove_deprels(self, feats_and_tds):
        '''Removes deprels from feat vec and trans/deprel vec

        Useful for converting LAS task to UAS
        '''
        for feat_vec, td_vec in feats_and_tds:
            if td_vec[0]:
                td_vec = np.array((1, 0, 0), dtype=np.float32)
            elif np.sum(td_vec[1:len(self.deprel2id)]):
                td_vec = np.array((0, 1, 0), dtype=np.float32)
            else:
                td_vec = np.array((0, 0, 1), dtype=np.float32)
            yield feat_vec[:2], td_vec

    def feats_and_tds2minibatches(
            self, feats_and_tds, max_batch_size, has_deprels=True):
        '''Convert (feats,...),(trans, deprel) pairs to minibatches

        Args:
            has_deprel : Whether features and labels have dependency
                labels (for LAS)
        '''
        batch_size = 0
        cur_batch = None
        for feat_vecs, td_vec in feats_and_tds:
            if not batch_size:
                if has_deprels:
                    cur_batch = (
                        (
                            np.empty((max_batch_size, 18), dtype=np.float32),
                            np.empty((max_batch_size, 18), dtype=np.float32),
                            np.empty((max_batch_size, 12), dtype=np.float32),
                        ),
                        np.empty(
                            (max_batch_size, 2 * len(self.id2deprel) + 1),
                            dtype=np.float32,
                        ),
                    )
                else:
                    cur_batch = (
                        (
                            np.empty((max_batch_size, 18), dtype=np.float32),
                            np.empty((max_batch_size, 18), dtype=np.float32),
                        ),
                        np.empty((max_batch_size, 3), dtype=np.float32),
                    )
            for feat_vec_idx in range(len(feat_vecs)):
                cur_batch[0][feat_vec_idx][batch_size] = feat_vecs[feat_vec_idx]
            cur_batch[1][batch_size] = td_vec
            batch_size += 1
            if batch_size == max_batch_size:
                yield cur_batch
                batch_size = 0
        if batch_size:
            yield (
                tuple(feat[:batch_size] for feat in cur_batch[0]),
                cur_batch[1][:batch_size]
            )

    def td_vec2trans_deprel(
            self, td_vec, shift_id=PartialParse.shift_id,
            left_arc_id=PartialParse.left_arc_id,
            right_arc_id=PartialParse.right_arc_id,
            has_deprel=True):
        '''Convert a trans/deprel vector into a trans,deprel pair

        The maximum value index is chosen as the transition to take

        Args:
            has_deprel : whether td_vec contains the deprel or is
                simply a one-hot of transitions

        Returns:
            (transition_id, deprel) where deprel is always None if
            has_deprel is false
        '''
        max_idx = np.argmax(td_vec)
        if not has_deprel:
            return ((shift_id, left_arc_id, right_arc_id)[max_idx], None)
        elif not max_idx:
            return (shift_id, None)
        elif max_idx <= len(self.id2deprel):
            return (left_arc_id, self.id2deprel[max_idx - 1])
        else:
            return (
                right_arc_id, self.id2deprel[max_idx - len(self.id2deprel) - 1])

class TrainingIterable(object):
    '''Produces iterators over training data

    Args:
        graphs: the underlying CorpusView of DependencyGraphs
        transducer : an appropriately initialized Transducer
        seed : int
            The seed used to randomize the order per epoch
        max_batch_size : int
            The size of the batch to yield, except at edges. None yields
            one at a time
        las : bool
            Whether to set up input/labels for LAS task or UAS
        transition_cache : int or None
            How many transitions to cache before shuffling. If set,
            the graphs will be shuffled ahead of time, but the
            transitions within a graph will only be dispersed by
            approximately transition_cache / 2 samples. This option
            avoids storing all the training data in memory. If None,
            the entire data set will have to be stored in memory
    '''

    def __init__(
            self, graphs, transducer, seed=1234, max_batch_size=2048, las=True,
            transition_cache=None):
        self.graphs = graphs
        self.graphs_len = len(graphs)
        self.transducer = transducer
        self.rng = np.random.RandomState(seed)
        self.max_batch_size = max_batch_size
        if self.graphs_len > 2 ** 16  - 1:
            self.idx_map_dtype = np.uint32
        else:
            self.idx_map_dtype = np.uint16
        self.las = las
        self.transition_cache = transition_cache
        if self.transition_cache is not None:
            self.all_data = None
            self._len = sum(
                1 for _ in self.transducer.graphs2feats_and_tds(self.graphs))
        else:
            self._construct_all_data()
            self._len = len(self.all_data[0])

    def _construct_all_data(self):
        '''Pull all data for when transition_cache is None'''
        data_iter = self.transducer.graphs2feats_and_tds(self.graphs)
        if self.las:
            feat_vecs_lists = ([], [], [])
        else:
            feat_vecs_lists = ([], [])
            data_iter = self.transducer.remove_deprels(data_iter)
        td_vecs_list = []
        for feat_vecs, td_vec in data_iter:
            for feat_vec, feat_vecs_list in zip(feat_vecs, feat_vecs_lists):
                feat_vecs_list.append(feat_vec)
            td_vecs_list.append(td_vec)
        # all_data_feats = tuple(
        #     np.stack(feat_vecs_list, axis=0)
        #     for feat_vecs_list in feat_vecs_lists
        # )
        # all_data_tds = np.stack(td_vecs_list, axis=0).astype(np.float32)
        self.all_data = (
            feat_vecs_lists[0], feat_vecs_lists[1], feat_vecs_lists[2],
            td_vecs_list
        )

    def _shuffled_graphs(self):
        '''Get graphs, shuffled'''
        idx_map = np.arange(self.graphs_len, dtype=self.idx_map_dtype)
        self.rng.shuffle(idx_map)
        for idx_idx in range(self.graphs_len):
            yield self.graphs[idx_map[idx_idx]]

    def _shuffled_transitions(self, feats_and_tds):
        '''Shuffle transitions to the length of the transition_cache'''
        while True:
            cache = list(islice(feats_and_tds, self.transition_cache))
            if not cache:
                break
            self.rng.shuffle(cache)
            for elem in cache:
                yield elem

    def _shuffled_all_data(self):
        '''Shuffle all data (cached) and return one by one'''
        idx_map = np.arange(self._len, dtype=np.uint32)
        for idx_idx in range(self._len):
            idx = idx_map[idx_idx]
            yield (
                tuple(x[idx] for x in self.all_data[:3]),
                self.all_data[3][idx]
            )

    def get_iterator(self, shuffled=True):
        '''Get data iterator over an epoch

        Args:
            shuffled : bool
                Whether to shuffle the data
        '''
        if self.transition_cache is None:
            if shuffled:
                ret_iter = self._shuffled_all_data()
            else:
                ret_iter = ((tup[:3], tup[3]) for tup in zip(*self.all_data))
        else:
            if shuffled:
                ret_iter = self._shuffled_graphs()
            else:
                ret_iter = self.graphs
            ret_iter = self.transducer.graphs2feats_and_tds(ret_iter)
            if shuffled and self.transition_cache != 0:
                ret_iter = self._shuffled_transitions(ret_iter)
            if not self.las:
                ret_iter = self.transducer.remove_deprels(ret_iter)
        ret_iter = self.transducer.feats_and_tds2minibatches(
            ret_iter, self.max_batch_size, has_deprels=self.las)
        return ret_iter

    def __len__(self):
        return self._len

    def __iter__(self):
        return self.get_iterator()

def score_arcs(actuals, expecteds, las=True):
    '''Return UAS or LAS score of arcs'''
    accum = accumL = 0.
    tokens = 0
    for actual, expected in zip(actuals, expecteds):
        sent_len = len(expected)
        #assert len(actual) == sent_len, \
        #    "Invalid number of dependencies! Expected {}, got {}".format(
        #        sent_len, len(actual))
        tokens += sent_len
        ex = {}
        for (ex_h, ex_d, ex_dep) in expected:
            ex[ex_d] = (ex_h, ex_dep)
        #actual = sorted(actual, key=lambda x: x[1]) # sort by dependant
        #expected = sorted(expected, key=lambda x: x[1])
        for (ac_h, ac_d, ac_dep) in actual:
            #assert ex_d == ac_d, \
            #    "Dependants don't match! Should be one for each word"
            if las:
                accumL += (ex.get(ac_d) == (ac_h, ac_dep))
            accum += int(ex.get(ac_d) is not None and ex.get(ac_d)[0] == ac_h)
    return ((accumL / max(tokens, 1)) if las else None, accum / max(tokens, 1))

def load_and_preprocess_data(
        data_set=mystery, word_embedding_path='word2vec.pkl.gz', las=True,
        max_batch_size=2048, transition_cache=None, seed=1234):
    '''Get train/test data

    See TrainingIterable for description of args

    Returns:
         a tuple of
         - a Transducer object
         - a word embedding matrix
         - a training data iterable
         - an iterable over dev sentences
         - an iterable over dev dependencies (arcs)
         - an iterable over test sentences
         - an iterable over test dependencies (arcs)
    '''
    print('Loading word embeddings...', end='')
    stdout.flush()
    if word_embedding_path.endswith('.gz'):
        with gz_open(word_embedding_path, 'rb') as file_obj:
            word_list, word_embeddings = load(file_obj)
    else:
        with open(word_embedding_path, 'rb') as file_obj:
            word_list, word_embeddings = load(file_obj)
    # add null embedding (we'll initialize later)
    word_embeddings = np.append(
        word_embeddings,
        np.empty((1, word_embeddings.shape[1]), dtype=np.float32),
        axis=0
    )
    print('there are {} word embeddings.'.format(word_embeddings.shape[0]))
    print('Determining POS tags...', end='')
    stdout.flush()
    tag_set = set()
    for sentence in data_set.tagged_sents('train.conll'):
        for _, tag in sentence:
            tag_set.add(tag)
    tag_list = sorted(tag_set)
    print('there are {} tags.'.format(len(tag_list)))
    training_graphs = data_set.parsed_sents('train.conll')
    if las:
        print('Determining deprel labels...', end='')
        stdout.flush()
        deprel_set = set()
        for graph in training_graphs:
            for node in graph.nodes.values():
                if node['address']: # not root
                    deprel_set.add(node['rel'])
        deprel_list = sorted(deprel_set)
        print('there are {} deprel labels.'.format(len(deprel_list)))
    else:
        deprel_list = []
    transducer = Transducer(word_list, tag_list, deprel_list)
    print('Getting training data...', end='')
    stdout.flush()
    training_data = TrainingIterable(
        training_graphs, transducer,
        max_batch_size=max_batch_size, las=las,
        transition_cache=transition_cache, seed=seed,
    )
    # use training's rng to initialize null embedding
    word_embeddings[-1] = training_data.rng.uniform(-.01, .01, 50)
    print('there are {} samples.'.format(len(training_data)))
    print('Getting dev data...', end='')
    stdout.flush()
    dev_sentences = data_set.tagged_sents('dev.conll')
    dev_arcs = tuple(
        list(transducer.graph2arc(graph, include_deprel=las))
        for graph in data_set.parsed_sents('dev.conll')
    )
    print('there are {} samples.'.format(len(dev_arcs)))
    print('Getting test data...', end='')
    stdout.flush()
    test_sentences = data_set.tagged_sents('test.conll')
    test_arcs = tuple(
        list(transducer.graph2arc(graph, include_deprel=las))
        for graph in data_set.parsed_sents('test.conll')
    )
    print('there are {} samples.'.format(len(test_arcs)))
    return (
        transducer, word_embeddings, training_data,
        dev_sentences, dev_arcs, test_sentences, test_arcs
    )
