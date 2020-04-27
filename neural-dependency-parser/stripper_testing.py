from __future__ import print_function
from tensorflow.core.framework import graph_pb2
import tensorflow as tf
import numpy as np
from tensorflow.examples.tutorials.mnist import input_data
from google.protobuf import text_format


def display_nodes(nodes):
	with open("model_structure_tmp", "a") as f:
	    for i, node in enumerate(nodes):
	        f.write('%d %s %s\n' % (i, node.name, node.op))
	        [f.write(u'└─── %d ─ %s\n' % (i, n)) for i, n in enumerate(node.input)]


graph = tf.GraphDef()
with tf.gfile.Open('./model.pbtxt', 'r') as f:
    text_format.Parse(f.read(), graph)
    


display_nodes(graph.node)