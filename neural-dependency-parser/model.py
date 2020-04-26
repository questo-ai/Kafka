from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import time

from itertools import islice
from sys import stdout
from tempfile import NamedTemporaryFile
import tensorflow as tf
from utils.model import Model
from data import load_and_preprocess_data
from data import score_arcs
from initialization import xavier_weight_init
from parser import minibatch_parse
from utils.generic_utils import Progbar

from tensorflow.python.tools.freeze_graph import freeze_graph
import tfcoreml

tf.flags.DEFINE_float("lr", 0.001, "learning rate")
tf.flags.DEFINE_integer("hidden", 0, "number of hidden layers if hidden > 0")
tf.flags.DEFINE_integer("hidden_size", 200, "hidden size for each layer")
tf.flags.DEFINE_integer("epochs", 1, "number of epochs")
# tf.flags.DEFINE_integer("epochs", 10, "number of epochs")
tf.flags.DEFINE_float("l2_beta", 0, "beta for computing l2 regularization")
tf.flags.DEFINE_string("activation", "relu", "activation function, can be relu or cube")
tf.flags.DEFINE_string("optimizer", "adam", "optimizer, can be adam or adagrad")
tf.flags.DEFINE_string("output", "", "output filename for arcs")

FLAGS = tf.app.flags.FLAGS

class Config(object):
    """Holds model hyperparams and data information.

    The config class is used to store various hyperparameters and dataset
    information parameters. Model objects are passed a Config() object at
    instantiation.
    """
    n_word_ids = None # inferred
    n_tag_ids = None # inferred
    n_deprel_ids = None # inferred
    n_word_features = None # inferred
    n_tag_features = None # inferred
    n_deprel_features = None # inferred
    n_classes = None # inferred
    dropout = 0.5
    embed_size = None # inferred
    hidden_size = FLAGS.hidden_size 
    batch_size = 2048
    n_epochs = FLAGS.epochs
    lr = FLAGS.lr
    l2_beta = FLAGS.l2_beta
    l2_loss = 0

class ParserModel(Model):
    """
    Implements a feedforward neural network with an embedding layer and single hidden layer.
    This network will predict which transition should be applied to a given partial parse
    configuration.
    """

    def add_placeholders(self):
        """Generates placeholder variables to represent the input tensors

        These placeholders are used as inputs by the rest of the model
        building and will be fed data during training.  Note that when
        "None" is in a placeholder's shape, it's flexible (so we can use
        different batch sizes without rebuilding the model).

        Adds following nodes to the computational graph

        word_id_placeholder:
            Word feature placeholder of shape (None, n_word_features),
            type tf.int32
        tag_id_placeholder:
            POS tag feature placeholder of shape (None, n_tag_features),
            type tf.int32
        deprel_id_placeholder:
            Dependency relation feature placeholder of shape
            (None, n_deprel_features), type tf.int32
        class_placeholder:
            Labels placeholder tensor of shape (None, n_classes),
            type tf.float32
        dropout_placeholder: Dropout value placeholder (scalar), type
            tf.float32

        Add these placeholders to self as attributes
            self.word_id_placeholder
            self.tag_id_placeholder
            self.deprel_id_placeholder
            self.class_placeholder
            self.dropout_placeholder
        """
        self.word_id_placeholder = tf.placeholder(
            tf.int32,
            shape=(None, self.config.n_word_features)
        )
        self.tag_id_placeholder = tf.placeholder(
            tf.int32,
            shape=(None, self.config.n_tag_features)
        )
        self.deprel_id_placeholder = tf.placeholder(
            tf.int32,
            shape=(None, self.config.n_deprel_features)
        )
        self.class_placeholder = tf.placeholder(
            tf.float32,
            shape=(None, self.config.n_classes)
        )
        self.dropout_placeholder = tf.placeholder(
            tf.float32,
            shape=()
        )

    def create_feed_dict(
            self, word_id_batch, tag_id_batch, deprel_id_batch,
            class_batch=None, dropout=1):
        """Creates the feed_dict for the dependency parser.

        A feed_dict takes the form of:

        feed_dict = {
                <placeholder>: <tensor of values to be passed for placeholder>,
                ....
        }

        The keys for the feed_dict should be a subset of the placeholder
        tensors created in add_placeholders. When an argument is None,
        don't add it to the feed_dict.

        Args:
            word_id_batch: A batch of word id features
            tag_id_batch: A batch of POS tag id features
            deprel_id_batch: A batch of dependency relation id features
            class_batch: A batch of class label data
            dropout: The dropout rate
        Returns:
            feed_dict: The feed dictionary mapping from placeholders to values.
        """
        feed_dict = {}

        if type(word_id_batch) != type(None):
            feed_dict[self.word_id_placeholder] = word_id_batch
        if type(tag_id_batch) != type(None):
            feed_dict[self.tag_id_placeholder] = tag_id_batch
        if type(deprel_id_batch) != type(None):
            feed_dict[self.deprel_id_placeholder] = deprel_id_batch
        if type(class_batch) != type(None):
            feed_dict[self.class_placeholder] = class_batch
        if type(dropout) != type(None):
            feed_dict[self.dropout_placeholder] = dropout

        return feed_dict

    def add_embeddings(self):
        """Creates embeddings that map word, tag, deprels to vectors

        Embedding layers convert (sparse) ID representations to dense,
        lower-dimensional representations. Inputs are integers, outputs
        are floats.

         - Create 3 embedding matrices, one for each of the input types.
           Input values index the rows of the matrices to extract. The
           max bound (exclusive) on the values in the input can be found
           in {n_word_ids, n_tag_ids, n_deprel_ids}
           After lookup, the resulting tensors should each be of shape
           (None, n, embed_size), where n is one of
           {n_word_features, n_tag_features, n_deprel_features}.
         - Initialize the word_id embedding matrix with
           self.word_embeddings. Initialize the other two matrices
           with the Xavier initialization you implemented
         - Reshape the embedding tensors into shapes
           (None, n * embed_size)

        ** Embedding matrices should be variables, not constants! **

        Use tf.nn.embedding_lookup. Also take a look at tf.reshape

        Returns:
            word_embeddings : tf.Tensor of type tf.float32 and shape
                (None, n_word_features * embed_size)
            tag_embeddings : tf.float32 (None, n_tag_features * embed_size)
            deprel_embeddings : tf.float32
                (None, n_deprel_features * embed_size)
        """

        word_variables = tf.Variable(self.word_embeddings)
        word_embeddings = tf.nn.embedding_lookup(
            word_variables,
            self.word_id_placeholder
        )
        word_embeddings = tf.reshape(
            word_embeddings,
            shape=(-1, self.config.n_word_features * self.config.embed_size)
        )

        xavier_initializer = xavier_weight_init()

        tag_variable = tf.Variable(xavier_initializer((self.config.n_tag_ids, self.config.embed_size)))
        tag_embeddings = tf.nn.embedding_lookup(
            tag_variable,
            self.tag_id_placeholder
        )
        tag_embeddings = tf.reshape(
            tag_embeddings,
            shape=(-1, self.config.n_tag_features * self.config.embed_size)
        )

        deprel_variable = tf.Variable(xavier_initializer((self.config.n_deprel_ids, self.config.embed_size)))
        deprel_embeddings = tf.nn.embedding_lookup(
            deprel_variable,
            self.deprel_id_placeholder
        )
        deprel_embeddings = tf.reshape(
            deprel_embeddings,
            shape=(-1, self.config.n_deprel_features * self.config.embed_size)
        )

        if self.config.l2_beta:
            # include tag_variable and deprel_variable into l2 regularization
            self.config.l2_loss += tf.nn.l2_loss(tag_variable) + tf.nn.l2_loss(deprel_variable)

        # print(word_embeddings.shape, tag_embeddings.shape, deprel_embeddings.shape)
        return word_embeddings, tag_embeddings, deprel_embeddings

    def add_prediction_op(self):
        """Adds the single layer neural network

        The l
            h = Relu(W_w x_w + W_t x_t + W_d x_d + b1)
            h_drop = Dropout(h, dropout_rate)
            pred = h_drop U + b2

        Note that we are not applying a softmax to pred. The softmax
        will instead be done in the add_loss_op function, which improves
        efficiency because we can use
            tf.nn.softmax_cross_entropy_with_logits
        Excluding the softmax in predictions won't change the expected
        transition.

        Use the Xavier initializer from initialization.py for W_ and
        U. Initialize b1 and b2 with zeros.

        The dimensions of the various variables you will need to create
        are:
            W_w : (n_word_features * embed_size, hidden_size)
            W_t : (n_tag_features * embed_size, hidden_size)
            W_d : (n_deprel_features * embed_size, hidden_size)
            b1: (hidden_size,)
            U:  (hidden_size, n_classes)
            b2: (n_classes)

        Use the value self.dropout_placeholder in tf.nn.dropout directly

        Returns:
            pred: tf.Tensor of shape (batch_size, n_classes)
        """
        x_w, x_t, x_d = self.add_embeddings()

        xavier_initializer = tf.contrib.layers.xavier_initializer()

        W_w = tf.Variable(xavier_initializer((self.config.n_word_features * self.config.embed_size, self.config.hidden_size)))
        W_t = tf.Variable(xavier_initializer((self.config.n_tag_features * self.config.embed_size, self.config.hidden_size)))
        W_d = tf.Variable(xavier_initializer((self.config.n_deprel_features* self.config.embed_size, self.config.hidden_size)))
        b1 = tf.Variable(tf.zeros((self.config.hidden_size,)))
        U = tf.Variable(xavier_initializer((self.config.hidden_size, self.config.n_classes)))
        b2 = tf.Variable(tf.zeros((self.config.n_classes)))

        x = tf.matmul(x_w, W_w) + tf.matmul(x_t, W_t) + tf.matmul(x_d, W_d) + b1

        print("\n\t" + FLAGS.activation + " activation function")

        # compute first hidden layer
        if FLAGS.activation == 'cube':
            # cube activation function
            h = tf.pow(x, tf.constant(3, dtype=tf.float32))
        else:
            h = tf.nn.relu(x)

        # add all weights and biases for l2 regularization
        if self.config.l2_beta:
            print("\tl2 regularization with beta " + str(self.config.l2_beta))
            self.config.l2_loss += tf.nn.l2_loss(W_w) + tf.nn.l2_loss(W_t) + \
                                  tf.nn.l2_loss(W_d) + tf.nn.l2_loss(b1) + \
                                  tf.nn.l2_loss(U) + tf.nn.l2_loss(b2)

        print("\t" + str(FLAGS.hidden + 1) + " hidden layer(s) with size " + str(FLAGS.hidden_size))

        if FLAGS.hidden:
            # initialize weights and biases for hidden layers
            w, b = {}, {}
            for i in range(FLAGS.hidden):
                w[i] = tf.Variable(xavier_initializer((self.config.hidden_size, self.config.hidden_size)))
                b[i] = tf.Variable(tf.random.uniform([self.config.hidden_size]))
                # b[i] = tf.Variable(tf.random_normal([self.config.hidden_size]))

            def hidden_layers(x):
                layer = tf.nn.relu(tf.matmul(x, w[0]) + b[0])
                for i in range(1, FLAGS.hidden):
                    layer = tf.nn.relu(tf.matmul(layer, w[i]) + b[i])
                return layer
            
            # apply dropout then compute additional hidden layers
            h_drop = tf.nn.dropout(h, self.dropout_placeholder)
            layers = hidden_layers(h_drop)
            pred = tf.matmul(layers, U) + b2

            # add l2 loss for hidden weights and biases
            if self.config.l2_beta:
                for i in range(FLAGS.hidden):
                    self.config.l2_loss += tf.nn.l2_loss(w[i]) + tf.nn.l2_loss(b[i])
        else:
            h_drop = tf.nn.dropout(h, self.dropout_placeholder)
            pred = tf.matmul(h_drop, U) + b2

        pred_activated = tf.nn.softmax(pred, name="output/softmax")

        return pred

    def add_loss_op(self, pred):
        """Adds Ops for the loss function to the computational graph.

        In this case we are using cross entropy loss. The loss should be
        averaged over all examples in the current minibatch.

        Use tf.nn.softmax_cross_entropy_with_logits to simplify your
        implementation. You might find tf.reduce_mean useful.

        Args:
            pred:
                A tensor of shape (batch_size, n_classes) containing
                the output of the neural network before the softmax layer.
        Returns:
            loss: A 0-d tensor (scalar)
        """

        loss = tf.reduce_mean(
            tf.nn.softmax_cross_entropy_with_logits_v2(
                labels=self.class_placeholder,
                logits=pred
            )
        )

        if self.config.l2_beta:
            # compute l2 regularization
            loss = tf.reduce_mean(loss + self.config.l2_beta * self.config.l2_loss)

        return loss

    def add_training_op(self, loss):
        """Sets up the training Ops.

        Creates an optimizer and applies the gradients to all trainable
        variables. The Op returned by this function is what must be
        passed to the `sess.run()` call to cause the model to train.

        Use tf.train.AdamOptimizer for this model.
        Calling optimizer.minimize() will return a train_op object.

        Args:
            loss: Loss tensor, from cross_entropy_loss.
        Returns:
            train_op: The Op for training.
        """
        print("\t" + FLAGS.optimizer + " optimizer with learning rate " + str(self.config.lr))

        if FLAGS.optimizer == 'adagrad':
            optimizer = tf.train.AdagradOptimizer(self.config.lr)
        else:
            optimizer = tf.train.AdamOptimizer(self.config.lr)

        train_op = optimizer.minimize(loss, global_step=tf.train.get_global_step())

        return train_op

    def fit_batch(
            self,
            word_id_batch, tag_id_batch, deprel_id_batch, class_batch):
        feed = self.create_feed_dict(
            word_id_batch, tag_id_batch, deprel_id_batch,
            class_batch=class_batch, dropout=self.config.dropout
        )
        _, loss = self.sess.run([self.train_op, self.loss], feed_dict=feed)
        return loss

    def fit_epoch(self, train_data, batch_size=None, incl_progbar=True):
        '''Fit on training data for an epoch'''
        if incl_progbar:
            progbar = Progbar(target=len(train_data)*batch_size if batch_size else len(train_data))
        for (word_id_batch, tag_id_batch, deprel_id_batch), class_batch in \
                train_data:
            loss = self.fit_batch(
                word_id_batch, tag_id_batch, deprel_id_batch, class_batch)
            if incl_progbar:
                progbar.add(word_id_batch.shape[0], [("Cross-entropy", loss)])

    def predict_on_batch(self, inputs_batch):
        feed = self.create_feed_dict(*inputs_batch)
        predictions = self.sess.run(self.pred, feed_dict=feed)
        return predictions

    def predict(self, partial_parses):
        '''Use this model to predict the next transitions/deprels of pps'''
        feats = self.transducer.pps2feats(partial_parses)
        td_vecs = self.predict_on_batch(feats)
        preds = [
            self.transducer.td_vec2trans_deprel(td_vec) for td_vec in td_vecs]
        return preds

    def eval(self, sentences, ex_arcs):
        '''LAS on either training or test sets'''
        act_arcs = minibatch_parse(sentences, self, self.config.batch_size)
        ex_arcs = tuple([(a[0], a[1], self.transducer.id2deprel[a[2]]) for a in pp] for pp in ex_arcs)
        if FLAGS.output:
            import json
            with open(FLAGS.output, 'w+') as f:
                for row in act_arcs:
                    f.write('%s\n' % json.dumps(row))
        return score_arcs(act_arcs, ex_arcs)

    def __init__(self, transducer, sess, config, word_embeddings):
        self.transducer = transducer
        # we have to store the session here in order to avoid passing
        # the session to minibatch_parse.
        self.sess = sess
        self.word_embeddings = word_embeddings
        self.config = config
        self.build()


def main(debug):
    '''Main function

    Args:
    debug :
        whether to use a fraction of the data. Make sure to set to False
        when you're ready to train your model for real!
    '''
    print(80 * "=")
    print("INITIALIZING")
    print(80 * "=")
    config = Config()
    data = load_and_preprocess_data(
        max_batch_size=config.batch_size)
    transducer, word_embeddings, train_data = data[:3]
    dev_sents, dev_arcs = data[3:5]
    test_sents, test_arcs = data[5:]
    config.n_word_ids = len(transducer.id2word) + 1 # plus null
    config.n_tag_ids = len(transducer.id2tag) + 1
    config.n_deprel_ids = len(transducer.id2deprel) + 1
    config.embed_size = word_embeddings.shape[1]
    for (word_batch, tag_batch, deprel_batch), td_batch in \
            train_data.get_iterator(shuffled=False):
        config.n_word_features = word_batch.shape[-1]
        config.n_tag_features = tag_batch.shape[-1]
        config.n_deprel_features = deprel_batch.shape[-1]
        config.n_classes = td_batch.shape[-1]
        break
    print(
        'Word feat size: {}, tag feat size: {}, deprel feat size: {}, '
        'classes size: {}'.format(
            config.n_word_features, config.n_tag_features,
            config.n_deprel_features, config.n_classes))
    if debug:
        dev_sents = dev_sents[:500]
        dev_arcs = dev_arcs[:500]
        test_sents = test_sents[:500]
        test_arcs = test_arcs[:500]
    if not debug:
        weight_file = NamedTemporaryFile(suffix='.weights')
        # weight_file = open("something.weights", mode=)
    with tf.Graph().as_default(), tf.Session() as session:
        print("Building model...", end=' ')
        start = time.time()
        model = ParserModel(transducer, session, config, word_embeddings)
        print("took {:.2f} seconds\n".format(time.time() - start))
        init = tf.global_variables_initializer()
        session.run(init)
        
        saver = None if debug else tf.train.Saver()
        print(80 * "=")
        print("TRAINING")
        print(80 * "=")
        best_las = 0.
        for epoch in range(config.n_epochs):
            print('Epoch {}'.format(epoch))

            # saver.restore(session, "model.ckpt")
            graph = session.graph
            if debug:
                model.fit_epoch(list(islice(train_data,3)), config.batch_size)
            else:
                model.fit_epoch(train_data)
            stdout.flush()
            dev_las, dev_uas = model.eval(dev_sents, dev_arcs)
            best = dev_las > best_las
            if best:
                best_las = dev_las
                if not debug:
                    saver.save(session, "model.ckpt")
                    tf.io.write_graph(session.graph_def, './', 'model.pbtxt')
                    

            print('Validation LAS: ', end='')
            print('{:.2f}{}'.format(dev_las, ' (BEST!), ' if best else ', '))
            print('Validation UAS: ', end='')
            print('{:.2f}'.format(dev_uas))
        if not debug:
            print()
            print(80 * "=")
            print("TESTING")
            print(80 * "=")
            print("Restoring the best model weights found on the dev set")
            saver.restore(session, "model.ckpt")
            stdout.flush()
            las,uas = model.eval(test_sents, test_arcs)
            if las:
                print("Test LAS: ", end='')
                print('{:.2f}'.format(las), end=', ')
            print("Test UAS: ", end='')
            print('{:.2f}'.format(uas))
            print("Done!")
    return 0


if __name__ == '__main__':
    main(False)
