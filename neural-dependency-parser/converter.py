## =====================
## Stage 1: Freeze model
## =====================

import numpy as np
from tensorflow.python.tools.freeze_graph import freeze_graph
import tfcoreml

print("="*80)
print("freezing graph...")
print("="*80)

graph_def_file = 'checkpoints/model.pbtxt'
checkpoint_file = 'checkpoints/model.ckpt'
frozen_model_file = 'checkpoints/frozen_model.pb'

output_node_names = 'output/td_vec' 

freeze_graph(input_graph=graph_def_file,
             input_saver="",
             input_binary=False,
             input_checkpoint=checkpoint_file,
             output_node_names=output_node_names,
             restore_op_name="save/restore_all",
             filename_tensor_name="save/Const:0",
             output_graph=frozen_model_file,
             clear_devices=True,
             initializer_nodes="")

print("="*80)
print("graph frozen!")
print("="*80)


## ===============================
## Stage 2: Optimize for inference
## ===============================


from tensorflow.python.tools import optimize_for_inference_lib
from tensorflow.python.framework import dtypes
from tensorflow.core.framework import graph_pb2
from tensorflow.python.platform import gfile

print("="*80)
print("optimizing for inference...")
print("="*80)

input_names = ["Placeholder","Placeholder_1","Placeholder_2"]
input_dtypes_unparsed = [dtypes.int32.as_datatype_enum, dtypes.int32.as_datatype_enum, dtypes.int32.as_datatype_enum]
output_names = ["output/td_vec"]
toco_compatible = False # "If true, only use ops compatible with Tensorflow Lite Optimizing Converter."
optimized_model_path = "checkpoints/frozen_model_optimized.pb"

input_graph_def = graph_pb2.GraphDef()
with gfile.Open(frozen_model_file, "rb") as f:
    data = f.read()

input_graph_def.ParseFromString(data)

def _parse_placeholder_types(values):
    """Extracts placeholder types from a comma separate list."""
    values = [int(value) for value in values]
    return values if len(values) > 1 else values[0]


output_graph_def = optimize_for_inference_lib.optimize_for_inference(
    input_graph_def,
    input_names,
    output_names,
    _parse_placeholder_types(input_dtypes_unparsed),
    toco_compatible)

with gfile.GFile(optimized_model_path, "w") as f:
    f.write(output_graph_def.SerializeToString())


print("="*80)
print("optimizing for inference successful!")
print("="*80)


## ==========================
## Stage 3: Convert to CoreML
## ==========================

print("="*80)
print("converting to coreml...")
print("="*80)

input_tensor_shapes = {"Placeholder": [1,18], "Placeholder_1":[1,18], "Placeholder_2":[1,12], "Placeholder_3":[1,83], "Placeholder_4":[1]} # batch size is 1
coreml_model_file = 'checkpoints/model.mlmodel' # output CoreML file
output_tensor_names = output_names

coreml_model = tfcoreml.convert(
        minimum_ios_deployment_target="13",
        tf_model_path=optimized_model_path, 
        mlmodel_path=coreml_model_file, 
        input_name_shape_dict=input_tensor_shapes,
        output_feature_names=output_tensor_names,
        add_custom_layers=True)

print("="*80)
print("converted to coreml successfully!")
print("="*80)


