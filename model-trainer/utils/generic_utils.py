"""Copied from keras (https://github.com/fchollet/keras/)"""
from __future__ import absolute_import

import numpy as np

import time
import sys
import six
import marshal
import types as python_types
import inspect

_GLOBAL_CUSTOM_OBJECTS = {}


class CustomObjectScope(object):
    """Provides a scope that changes to `_GLOBAL_CUSTOM_OBJECTS` cannot escape.

    Code within a `with` statement will be able to access custom objects
    by name. Changes to global custom objects persist
    within the enclosing `with` statement. At end of the `with` statement,
    global custom objects are reverted to state
    at beginning of the `with` statement.

    # Example

    Consider a custom object `MyObject` (e.g. a class):

    ```python
        with CustomObjectScope({'MyObject':MyObject}):
            layer = Dense(..., kernel_regularizer='MyObject')
            # save, load, etc. will recognize custom object by name
    ```
    """

    def __init__(self, *args):
        self.custom_objects = args
        self.backup = None

    def __enter__(self):
        self.backup = _GLOBAL_CUSTOM_OBJECTS.copy()
        for objects in self.custom_objects:
            _GLOBAL_CUSTOM_OBJECTS.update(objects)
        return self

    def __exit__(self, *args, **kwargs):
        _GLOBAL_CUSTOM_OBJECTS.clear()
        _GLOBAL_CUSTOM_OBJECTS.update(self.backup)


def custom_object_scope(*args):
    """Provides a scope that changes to `_GLOBAL_CUSTOM_OBJECTS` cannot escape.

    Convenience wrapper for `CustomObjectScope`.
    Code within a `with` statement will be able to access custom objects
    by name. Changes to global custom objects persist
    within the enclosing `with` statement. At end of the `with` statement,
    global custom objects are reverted to state
    at beginning of the `with` statement.

    # Example

    Consider a custom object `MyObject`

    ```python
        with custom_object_scope({'MyObject':MyObject}):
            layer = Dense(..., kernel_regularizer='MyObject')
            # save, load, etc. will recognize custom object by name
    ```

    # Arguments
        *args: Variable length list of dictionaries of name,
            class pairs to add to custom objects.

    # Returns
        Object of type `CustomObjectScope`.
    """
    return CustomObjectScope(*args)


def get_custom_objects():
    """Retrieves a live reference to the global dictionary of custom objects.

    Updating and clearing custom objects using `custom_object_scope`
    is preferred, but `get_custom_objects` can
    be used to directly access `_GLOBAL_CUSTOM_OBJECTS`.

    # Example

    ```python
        get_custom_objects().clear()
        get_custom_objects()['MyObject'] = MyObject
    ```

    # Returns
        Global dictionary of names to classes (`_GLOBAL_CUSTOM_OBJECTS`).
    """
    return _GLOBAL_CUSTOM_OBJECTS


def serialize_keras_object(instance):
    if instance is None:
        return None
    if hasattr(instance, 'get_config'):
        return {
            'class_name': instance.__class__.__name__,
            'config': instance.get_config()
        }
    if hasattr(instance, '__name__'):
        return instance.__name__
    else:
        raise ValueError('Cannot serialize', instance)


def deserialize_keras_object(identifier, module_objects=None,
                             custom_objects=None,
                             printable_module_name='object'):
    if isinstance(identifier, dict):
        # In this case we are dealing with a Keras config dictionary.
        config = identifier
        if 'class_name' not in config or 'config' not in config:
            raise ValueError('Improper config format: ' + str(config))
        class_name = config['class_name']
        if custom_objects and class_name in custom_objects:
            cls = custom_objects[class_name]
        elif class_name in _GLOBAL_CUSTOM_OBJECTS:
            cls = _GLOBAL_CUSTOM_OBJECTS[class_name]
        else:
            module_objects = module_objects or {}
            cls = module_objects.get(class_name)
            if cls is None:
                raise ValueError('Unknown ' + printable_module_name +
                                 ': ' + class_name)
        if hasattr(cls, 'from_config'):
            custom_objects = custom_objects or {}
            if has_arg(cls.from_config, 'custom_objects'):
                return cls.from_config(config['config'],
                                       custom_objects=dict(list(_GLOBAL_CUSTOM_OBJECTS.items()) +
                                                           list(custom_objects.items())))
            with CustomObjectScope(custom_objects):
                return cls.from_config(config['config'])
        else:
            # Then `cls` may be a function returning a class.
            # in this case by convention `config` holds
            # the kwargs of the function.
            custom_objects = custom_objects or {}
            with CustomObjectScope(custom_objects):
                return cls(**config['config'])
    elif isinstance(identifier, six.string_types):
        function_name = identifier
        if custom_objects and function_name in custom_objects:
            fn = custom_objects.get(function_name)
        elif function_name in _GLOBAL_CUSTOM_OBJECTS:
            fn = _GLOBAL_CUSTOM_OBJECTS[function_name]
        else:
            fn = module_objects.get(function_name)
            if fn is None:
                raise ValueError('Unknown ' + printable_module_name +
                                 ':' + function_name)
        return fn
    else:
        raise ValueError('Could not interpret serialized ' +
                         printable_module_name + ': ' + identifier)


def func_dump(func):
    """Serializes a user defined function.

    # Arguments
        func: the function to serialize.

    # Returns
        A tuple `(code, defaults, closure)`.
    """
    code = marshal.dumps(func.__code__).decode('raw_unicode_escape')
    defaults = func.__defaults__
    if func.__closure__:
        closure = tuple(c.cell_contents for c in func.__closure__)
    else:
        closure = None
    return code, defaults, closure


def func_load(code, defaults=None, closure=None, globs=None):
    """Deserializes a user defined function.

    # Arguments
        code: bytecode of the function.
        defaults: defaults of the function.
        closure: closure of the function.
        globs: dictionary of global objects.

    # Returns
        A function object.
    """
    if isinstance(code, (tuple, list)):  # unpack previous dump
        code, defaults, closure = code
        if isinstance(defaults, list):
            defaults = tuple(defaults)
    code = marshal.loads(code.encode('raw_unicode_escape'))
    if globs is None:
        globs = globals()
    return python_types.FunctionType(code, globs,
                                     name=code.co_name,
                                     argdefs=defaults,
                                     closure=closure)


def has_arg(fn, name, accept_all=False):
    """Checks if a callable accepts a given keyword argument.

    For Python 2, checks if there is an argument with the given name.

    For Python 3, checks if there is an argument with the given name, and
    also whether this argument can be called with a keyword (i.e. if it is
    not a positional-only argument).

    # Arguments
        fn: Callable to inspect.
        name: Check if `fn` can be called with `name` as a keyword argument.
        accept_all: What to return if there is no parameter called `name`
                    but the function accepts a `**kwargs` argument.

    # Returns
        bool, whether `fn` accepts a `name` keyword argument.
    """
    if sys.version_info < (3,):
        arg_spec = inspect.getargspec(fn)
        if accept_all and arg_spec.keywords is not None:
            return True
        return (name in arg_spec.args)
    elif sys.version_info < (3, 3):
        arg_spec = inspect.getfullargspec(fn)
        if accept_all and arg_spec.varkw is not None:
            return True
        return (name in arg_spec.args or
                name in arg_spec.kwonlyargs)
    else:
        signature = inspect.signature(fn)
        parameter = signature.parameters.get(name)
        if parameter is None:
            if accept_all:
                for param in signature.parameters.values():
                    if param.kind == inspect.Parameter.VAR_KEYWORD:
                        return True
            return False
        return (parameter.kind in (inspect.Parameter.POSITIONAL_OR_KEYWORD,
                                   inspect.Parameter.KEYWORD_ONLY))


class Progbar(object):
    """Displays a progress bar.

    # Arguments
        target: Total number of steps expected, None if unknown.
        interval: Minimum visual progress update interval (in seconds).
    """

    def __init__(self, target, width=30, verbose=1, interval=0.05):
        self.width = width
        self.target = target
        self.sum_values = {}
        self.unique_values = []
        self.start = time.time()
        self.last_update = 0
        self.interval = interval
        self.total_width = 0
        self.seen_so_far = 0
        self.verbose = verbose
        self._dynamic_display = ((hasattr(sys.stdout, 'isatty') and
                                  sys.stdout.isatty()) or
                                 'ipykernel' in sys.modules)

    def update(self, current, values=None, force=False):
        """Updates the progress bar.

        # Arguments
            current: Index of current step.
            values: List of tuples (name, value_for_last_step).
                The progress bar will display averages for these values.
            force: Whether to force visual progress update.
        """
        values = values or []
        for k, v in values:
            if k not in self.sum_values:
                self.sum_values[k] = [v * (current - self.seen_so_far),
                                      current - self.seen_so_far]
                self.unique_values.append(k)
            else:
                self.sum_values[k][0] += v * (current - self.seen_so_far)
                self.sum_values[k][1] += (current - self.seen_so_far)
        self.seen_so_far = current

        now = time.time()
        info = ' - %.0fs' % (now - self.start)
        if self.verbose == 1:
            if (not force and (now - self.last_update) < self.interval and
                    current < self.target):
                return

            prev_total_width = self.total_width
            if self._dynamic_display:
                sys.stdout.write('\b' * prev_total_width)
                sys.stdout.write('\r')
            else:
                sys.stdout.write('\n')

            if self.target is not None:
                numdigits = int(np.floor(np.log10(self.target))) + 1
                barstr = '%%%dd/%d [' % (numdigits, self.target)
                bar = barstr % current
                prog = float(current) / self.target
                prog_width = int(self.width * prog)
                if prog_width > 0:
                    bar += ('=' * (prog_width - 1))
                    if current < self.target:
                        bar += '>'
                    else:
                        bar += '='
                bar += ('.' * (self.width - prog_width))
                bar += ']'
            else:
                bar = '%7d/Unknown' % current

            self.total_width = len(bar)
            sys.stdout.write(bar)

            if current:
                time_per_unit = (now - self.start) / current
            else:
                time_per_unit = 0
            if self.target is not None and current < self.target:
                eta = time_per_unit * (self.target - current)
                if eta > 3600:
                    eta_format = '%d:%02d:%02d' % (eta // 3600, (eta % 3600) // 60, eta % 60)
                elif eta > 60:
                    eta_format = '%d:%02d' % (eta // 60, eta % 60)
                else:
                    eta_format = '%ds' % eta

                info = ' - ETA: %s' % eta_format
            else:
                if time_per_unit >= 1:
                    info += ' %.0fs/step' % time_per_unit
                elif time_per_unit >= 1e-3:
                    info += ' %.0fms/step' % (time_per_unit * 1e3)
                else:
                    info += ' %.0fus/step' % (time_per_unit * 1e6)

            for k in self.unique_values:
                info += ' - %s:' % k
                if isinstance(self.sum_values[k], list):
                    avg = np.mean(
                        self.sum_values[k][0] / max(1, self.sum_values[k][1]))
                    if abs(avg) > 1e-3:
                        info += ' %.4f' % avg
                    else:
                        info += ' %.4e' % avg
                else:
                    info += ' %s' % self.sum_values[k]

            self.total_width += len(info)
            if prev_total_width > self.total_width:
                info += (' ' * (prev_total_width - self.total_width))

            if self.target is not None and current >= self.target:
                info += '\n'

            sys.stdout.write(info)
            sys.stdout.flush()

        elif self.verbose == 2:
            if self.target is None or current >= self.target:
                for k in self.unique_values:
                    info += ' - %s:' % k
                    avg = np.mean(
                        self.sum_values[k][0] / max(1, self.sum_values[k][1]))
                    if avg > 1e-3:
                        info += ' %.4f' % avg
                    else:
                        info += ' %.4e' % avg
                info += '\n'

                sys.stdout.write(info)
                sys.stdout.flush()

        self.last_update = now

    def add(self, n, values=None):
        self.update(self.seen_so_far + n, values)
