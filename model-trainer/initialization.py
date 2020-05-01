import numpy as np
import tensorflow as tf

def xavier_weight_init():
    ''' Xavier Initialization '''
    def _xavier_initializer(shape):
        '''Defines an initializer for the Xavier distribution.

        Args:
            shape: tuple or 1d array, dimension of the weight tensor
        Returns:
            tf.Tensor with specified shape sampled from the Xavier distribution 
        '''
        epsilon = np.sqrt(6 / sum(shape))
        return tf.random_uniform(shape, minval=-epsilon, maxval=epsilon)
    return _xavier_initializer
