import numpy as np
from tensorflow.python.tools.freeze_graph import freeze_graph
import tfcoreml

graph_def_file = 'model.pbtxt'
checkpoint_file = 'model.ckpt'
frozen_model_file = 'frozen_model.pb'

# Output nodes. If there're multiple output ops, use comma separated string, e.g. "out1,out2".
output_node_names = 'output/softmax' 


# Call freeze graph
# freeze_graph(input_graph=graph_def_file,
#              input_saver="",
#              input_binary=False,
#              input_checkpoint=checkpoint_file,
#              output_node_names=output_node_names,
#              restore_op_name="save/restore_all",
#              filename_tensor_name="save/Const:0",
#              output_graph=frozen_model_file,
#              clear_devices=True,
#              initializer_nodes="")

# Strip unused subgraphs and save it as another frozen TF model
from tensorflow.python.tools import strip_unused_lib
from tensorflow.python.framework import dtypes
from tensorflow.python.platform import gfile
from tensorflow import GraphDef
from google.protobuf import text_format
from tensorflow.compat.v1.graph_util import remove_training_nodes

# input_node_names = ['Preprocessor/sub']
input_node_names = ["Placeholder", "Placeholder_1", "Placeholder_2","Placeholder_3","Placeholder_4"]


# # load graph def from file
# f = open("model.pbtxt", 'r')
# graph_def = GraphDef()
# file_content = f.read()  
# text_format.Merge(file_content, graph_def)

# remove_training_nodes(graph_def, protected_nodes=None)


# gdef = strip_unused_lib.strip_unused(
#         input_graph_def = graph_def,
#         input_node_names = input_node_names,
#         output_node_names = [output_node_names],
#         placeholder_type_enum = [dtypes.int32.as_datatype_enum, dtypes.int32.as_datatype_enum, dtypes.int32.as_datatype_enum, dtypes.float32.as_datatype_enum, dtypes.float32.as_datatype_enum])


# # Save the feature extractor to an output file
# frozen_model_file = 'stripped.pb'
# with gfile.GFile(frozen_model_file, "wb") as f:
#     f.write(gdef.SerializeToString())


"""
Step 2: Call converter
"""

# Provide these inputs in addition to inputs in Step 1
# A dictionary of input tensors' name and shape (with batch)
# input_tensor_shapes = {"Placeholder": [1,18], "Placeholder_1":[1,18], "Placeholder_2":[1,18], "Placeholder_3":[1,12], "Placeholder_4":[1]} # batch size is 1
input_tensor_shapes = {"Placeholder": [1,18], "Placeholder_1":[1,18], "Placeholder_2":[1,12], "Placeholder_3":[1,83], "Placeholder_4":[1]} # batch size is 1
# Output CoreML model path
coreml_model_file = 'model.mlmodel'
output_tensor_names = ['output/softmax']


# Call the converter
coreml_model = tfcoreml.convert(
		minimum_ios_deployment_target="13",
        tf_model_path=frozen_model_file, 
        mlmodel_path=coreml_model_file, 
        input_name_shape_dict=input_tensor_shapes,
        output_feature_names=output_tensor_names,
        add_custom_layers=True)

