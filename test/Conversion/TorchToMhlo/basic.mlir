// RUN: torch-mlir-opt <%s -convert-torch-to-mhlo -split-input-file -verify-diagnostics | FileCheck %s


// -----

// CHECK-LABEL:  func.func @torch.aten.clone$basic(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[NONE:.*]] = torch.constant.none
// CHECK:         %[[T1:.*]] = mhlo.copy %[[T0]] : tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.from_builtin_tensor %[[T1]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T2]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.clone$basic(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %none = torch.constant.none
  %0 = torch.aten.clone %arg0, %none : !torch.vtensor<[?,?],f32>, !torch.none -> !torch.vtensor<[?,?],f32>
  return %0 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.vtensor.literal$basic() -> !torch.vtensor<[],f32> {
// CHECK:           %[[VAL_0:.*]] = mhlo.constant dense<0.000000e+00> : tensor<f32>
// CHECK:           %[[VAL_1:.*]] = torch_c.from_builtin_tensor %[[VAL_0]] : tensor<f32> -> !torch.vtensor<[],f32>
// CHECK:           return %[[VAL_1]] : !torch.vtensor<[],f32>
func.func @torch.vtensor.literal$basic() -> !torch.vtensor<[],f32> {
  %0 = torch.vtensor.literal(dense<0.0> : tensor<f32>) : !torch.vtensor<[],f32>
  return %0 : !torch.vtensor<[],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.vtensor.literal$signed() -> !torch.vtensor<[2],si64> {
// CHECK:           %[[VAL_0:.*]] = mhlo.constant dense<1> : tensor<2xi64>
// CHECK:           %[[VAL_1:.*]] = torch_c.from_builtin_tensor %[[VAL_0]] : tensor<2xi64> -> !torch.vtensor<[2],si64>
// CHECK:           return %[[VAL_1]] : !torch.vtensor<[2],si64>
func.func @torch.vtensor.literal$signed() -> !torch.vtensor<[2],si64> {
  %0 = torch.vtensor.literal(dense<1> : tensor<2xsi64>) : !torch.vtensor<[2],si64>
  return %0 : !torch.vtensor<[2],si64>
}

// -----

// CHECK-LABEL:  func.func @torch.prim.NumToTensor.Scalar$basic(
// CHECK-SAME:         ) -> !torch.vtensor<[],si64> {
// CHECK:         %[[INT1:.*]] = torch.constant.int 1
// CHECK:         %[[T0:.*]] = torch_c.to_i64 %[[INT1]]
// CHECK:         %[[T1:.*]] = tensor.from_elements %[[T0]] : tensor<1xi64>
// CHECK:         %[[T2:.*]] = mhlo.convert %[[T1]] : tensor<1xi64>
// CHECK:         %[[T3:.*]] = mhlo.reshape %[[T2]] : (tensor<1xi64>) -> tensor<i64>
// CHECK:         %[[T4:.*]] = torch_c.from_builtin_tensor %[[T3]] : tensor<i64> -> !torch.vtensor<[],si64>
// CHECK:         return %[[T4]] : !torch.vtensor<[],si64>
func.func @torch.prim.NumToTensor.Scalar$basic() -> !torch.vtensor<[], si64> {
  %int1 = torch.constant.int 1
  %0 = torch.prim.NumToTensor.Scalar %int1 : !torch.int -> !torch.vtensor<[], si64>
  return %0 : !torch.vtensor<[], si64>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.contiguous(
// CHECK-SAME:                                     %[[VAL_0:.*]]: !torch.vtensor<[4,64],f32>) -> !torch.vtensor<[4,64],f32> {
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[4,64],f32> -> tensor<4x64xf32>
// CHECK:           %int0 = torch.constant.int 0
// CHECK:           %[[VAL_2:.*]] = torch_c.from_builtin_tensor %[[VAL_1]] : tensor<4x64xf32> -> !torch.vtensor<[4,64],f32>
// CHECK:           return %[[VAL_2]] : !torch.vtensor<[4,64],f32>
func.func @torch.aten.contiguous(%arg0: !torch.vtensor<[4,64],f32>) -> !torch.vtensor<[4,64],f32> {
  %int0 = torch.constant.int 0
  %0 = torch.aten.contiguous %arg0, %int0 : !torch.vtensor<[4,64],f32>, !torch.int -> !torch.vtensor<[4,64],f32>
  return %0 : !torch.vtensor<[4,64],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.reciprocal(
// CHECK-SAME:                                             %[[VAL_0:.*]]: !torch.vtensor<[?,?,?],f32>) -> !torch.vtensor<[?,?,?],f32> {
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[?,?,?],f32> -> tensor<?x?x?xf32>
// CHECK:           %[[VAL_2:.*]] = "chlo.constant_like"(%[[VAL_1]]) {value = 1.000000e+00 : f32} : (tensor<?x?x?xf32>) -> tensor<?x?x?xf32>
// CHECK:           %[[VAL_3:.*]] = mhlo.divide %[[VAL_2]], %[[VAL_1]] : tensor<?x?x?xf32>
// CHECK:           %[[VAL_4:.*]] = torch_c.from_builtin_tensor %[[VAL_3]] : tensor<?x?x?xf32> -> !torch.vtensor<[?,?,?],f32>
// CHECK:           return %[[VAL_4]] : !torch.vtensor<[?,?,?],f32>
func.func @torch.aten.reciprocal(%arg0: !torch.vtensor<[?,?,?],f32>) -> !torch.vtensor<[?,?,?],f32> {
  %0 = torch.aten.reciprocal %arg0 : !torch.vtensor<[?,?,?],f32> -> !torch.vtensor<[?,?,?],f32>
  return %0 : !torch.vtensor<[?,?,?],f32>
}


// -----

// CHECK-LABEL:   func.func @torch.aten.transpose$basic(
// CHECK-SAME:                                     %[[VAL_0:.*]]: !torch.vtensor<[4,3],f32>) -> !torch.vtensor<[3,4],f32> {
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[4,3],f32> -> tensor<4x3xf32>
// CHECK:           %[[VAL_2:.*]] = torch.constant.int 0
// CHECK:           %[[VAL_3:.*]] = torch.constant.int 1
// CHECK:           %[[VAL_4:.*]] = "mhlo.transpose"(%[[VAL_1]]) {permutation = dense<[1, 0]> : tensor<2xi64>} : (tensor<4x3xf32>) -> tensor<3x4xf32>
// CHECK:           %[[VAL_5:.*]] = torch_c.from_builtin_tensor %[[VAL_4]] : tensor<3x4xf32> -> !torch.vtensor<[3,4],f32>
// CHECK:           return %[[VAL_5]] : !torch.vtensor<[3,4],f32>
func.func @torch.aten.transpose$basic(%arg0: !torch.vtensor<[4,3],f32>) -> !torch.vtensor<[3,4],f32> {
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %0 = torch.aten.transpose.int %arg0, %int0, %int1 : !torch.vtensor<[4,3],f32>, !torch.int, !torch.int -> !torch.vtensor<[3,4],f32>
  return %0 : !torch.vtensor<[3,4],f32>
}


// -----

// CHECK-LABEL:   func.func @torch.aten.broadcast_to$dynamic_implicit(
// CHECK-SAME:                                             %[[VAL_0:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[8,4,?],f32> {
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:           %int-1 = torch.constant.int -1
// CHECK:           %int4 = torch.constant.int 4
// CHECK:           %int8 = torch.constant.int 8
// CHECK:           %[[VAL_2:.*]] = torch.prim.ListConstruct %int8, %int4, %int-1 : (!torch.int, !torch.int, !torch.int) -> !torch.list<int>
// CHECK:           %[[VAL_3:.*]] = torch_c.to_i64 %int8
// CHECK:           %[[VAL_4:.*]] = arith.index_cast %[[VAL_3:.*]] : i64 to index
// CHECK:           %[[VAL_5:.*]] = torch_c.to_i64 %int4
// CHECK:           %[[VAL_6:.*]] = arith.index_cast %[[VAL_5]] : i64 to index
// CHECK:           %[[VAL_7:.*]] = arith.constant 1 : index
// CHECK:           %[[VAL_8:.*]] = tensor.dim %[[VAL_1:.*]], %[[VAL_7]] : tensor<?x?xf32>
// CHECK:           %[[VAL_9:.*]] = tensor.from_elements %[[VAL_4]], %[[VAL_6]], %[[VAL_8]] : tensor<3xindex>
// CHECK:           %[[VAL_10:.*]] = "mhlo.dynamic_broadcast_in_dim"(%[[VAL_1]], %[[VAL_9]]) {broadcast_dimensions = dense<[1, 2]> : tensor<2xi64>} : (tensor<?x?xf32>, tensor<3xindex>) -> tensor<8x4x?xf32>
// CHECK:           %[[VAL_11:.*]] = torch_c.from_builtin_tensor %[[VAL_10]] : tensor<8x4x?xf32> -> !torch.vtensor<[8,4,?],f32>
// CHECK:           return %[[VAL_11]] : !torch.vtensor<[8,4,?],f32>
func.func @torch.aten.broadcast_to$dynamic_implicit(%arg0: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[8,4,?],f32> {
  %int-1 = torch.constant.int -1
  %int4 = torch.constant.int 4
  %int8 = torch.constant.int 8
  %0 = torch.prim.ListConstruct %int8, %int4, %int-1 : (!torch.int, !torch.int, !torch.int) -> !torch.list<int>
  %1 = torch.aten.broadcast_to %arg0, %0 : !torch.vtensor<[?,?],f32>, !torch.list<int> -> !torch.vtensor<[8,4,?],f32>
  return %1 : !torch.vtensor<[8,4,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.batch_norm$training(
// CHECK-SAME:                                              %[[VAL_0:.*]]: !torch.vtensor<[?,3,?,?],f32>) -> !torch.vtensor<[?,3,?,?],f32> {
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[?,3,?,?],f32> -> tensor<?x3x?x?xf32>
// CHECK:           %[[VAL_2:.*]] = mhlo.constant dense<0.000000e+00> : tensor<3xf32>
// CHECK:           %[[VAL_3:.*]] = mhlo.constant dense<1.000000e+00> : tensor<3xf32>
// CHECK:           %true = torch.constant.bool true
// CHECK:           %float1.000000e-01 = torch.constant.float 1.000000e-01
// CHECK:           %float1.000000e-05 = torch.constant.float 1.000000e-05
// CHECK:           %[[VAL_4:.*]] = arith.constant 1 : index
// CHECK:           %[[VAL_5:.*]] = tensor.dim %[[VAL_1]], %[[VAL_4]] : tensor<?x3x?x?xf32>
// CHECK:           %[[VAL_6:.*]] = tensor.from_elements %[[VAL_5]] : tensor<1xindex>
// CHECK:           %[[VAL_7:.*]], %[[VAL_8:.*]], %[[VAL_9:.*]] = "mhlo.batch_norm_training"(%[[VAL_1]], %[[VAL_3]], %[[VAL_2]]) {epsilon = 9.99999974E-6 : f32, feature_index = 1 : i64} : (tensor<?x3x?x?xf32>, tensor<3xf32>, tensor<3xf32>) -> (tensor<?x3x?x?xf32>, tensor<3xf32>, tensor<3xf32>)
// CHECK:           %[[VAL_8:.*]] = torch_c.from_builtin_tensor %[[VAL_7]] : tensor<?x3x?x?xf32> -> !torch.vtensor<[?,3,?,?],f32>
// CHECK:           return %[[VAL_8]] : !torch.vtensor<[?,3,?,?],f32>
func.func @torch.aten.batch_norm$training(%arg0: !torch.vtensor<[?,3,?,?],f32>) -> !torch.vtensor<[?,3,?,?],f32> {
  %0 = torch.vtensor.literal(dense<0.000000e+00> : tensor<3xf32>) : !torch.vtensor<[3],f32>
  %1 = torch.vtensor.literal(dense<1.000000e+00> : tensor<3xf32>) : !torch.vtensor<[3],f32>
  %true = torch.constant.bool true
  %float1.000000e-01 = torch.constant.float 1.000000e-01
  %float1.000000e-05 = torch.constant.float 1.000000e-05
  %2 = torch.aten.batch_norm %arg0, %1, %0, %0, %1, %true, %float1.000000e-01, %float1.000000e-05, %true : !torch.vtensor<[?,3,?,?],f32>, !torch.vtensor<[3],f32>, !torch.vtensor<[3],f32>, !torch.vtensor<[3],f32>, !torch.vtensor<[3],f32>, !torch.bool, !torch.float, !torch.float, !torch.bool -> !torch.vtensor<[?,3,?,?],f32>
  return %2 : !torch.vtensor<[?,3,?,?],f32>
}

// -----

// CHECK-LABEL:  func.func @torch.aten.batch_norm$inference(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,3,?,?],f32>) -> !torch.vtensor<[?,3,?,?],f32> {
// CHECK:         %[[T0:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,3,?,?],f32> -> tensor<?x3x?x?xf32>
// CHECK:         %[[T1:.*]] = mhlo.constant dense<0.000000e+00> : tensor<3xf32>
// CHECK:         %[[T2:.*]] = mhlo.constant dense<1.000000e+00> : tensor<3xf32>
// CHECK:         %[[TRUE:.*]] = torch.constant.bool true
// CHECK:         %[[FALSE:.*]] = torch.constant.bool false
// CHECK:         %[[FLOAT1:.*]].000000e-01 = torch.constant.float 1.000000e-01
// CHECK:         %[[FLOAT1:.*]].000000e-05 = torch.constant.float 1.000000e-05
// CHECK:         %[[C1:.*]] = arith.constant 1 : index
// CHECK:         %[[T3:.*]] = tensor.dim %[[T0]], %[[C1]] : tensor<?x3x?x?xf32>
// CHECK:         %[[T4:.*]] = tensor.from_elements %[[T3]] : tensor<1xindex>
// CHECK:         %[[T5:.*]] = tensor.cast %[[T0]] : tensor<?x3x?x?xf32> to tensor<?x3x?x?xf32>
// CHECK:         %[[T6:.*]] = "mhlo.batch_norm_inference"(%[[T5]], %[[T2]], %[[T1]], %[[T1]], %[[T2]]) {epsilon = 9.99999974E-6 : f32, feature_index = 1 : i64} : (tensor<?x3x?x?xf32>, tensor<3xf32>, tensor<3xf32>, tensor<3xf32>, tensor<3xf32>) -> tensor<?x3x?x?xf32>
// CHECK:         %[[T7:.*]] = tensor.cast %[[T6]] : tensor<?x3x?x?xf32> to tensor<?x3x?x?xf32>
// CHECK:         %[[T8:.*]] = torch_c.from_builtin_tensor %[[T7]] : tensor<?x3x?x?xf32> -> !torch.vtensor<[?,3,?,?],f32>
// CHECK:         return %[[T8]] : !torch.vtensor<[?,3,?,?],f32>
func.func @torch.aten.batch_norm$inference(%arg0: !torch.vtensor<[?,3,?,?],f32>) -> !torch.vtensor<[?,3,?,?],f32> {
  %0 = torch.vtensor.literal(dense<0.000000e+00> : tensor<3xf32>) : !torch.vtensor<[3],f32>
  %1 = torch.vtensor.literal(dense<1.000000e+00> : tensor<3xf32>) : !torch.vtensor<[3],f32>
  %true = torch.constant.bool true
  %false = torch.constant.bool false
  %float1.000000e-01 = torch.constant.float 1.000000e-01
  %float1.000000e-05 = torch.constant.float 1.000000e-05
  %2 = torch.aten.batch_norm %arg0, %1, %0, %0, %1, %false, %float1.000000e-01, %float1.000000e-05, %true : !torch.vtensor<[?,3,?,?],f32>, !torch.vtensor<[3],f32>, !torch.vtensor<[3],f32>, !torch.vtensor<[3],f32>, !torch.vtensor<[3],f32>, !torch.bool, !torch.float, !torch.float, !torch.bool -> !torch.vtensor<[?,3,?,?],f32>
  return %2 : !torch.vtensor<[?,3,?,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.batch_norm$no_bias_weight(
// CHECK-SAME:                                                    %[[VAL_0:.*]]: !torch.vtensor<[?,3,?,?],f32>) -> !torch.vtensor<[?,3,?,?],f32> {
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[?,3,?,?],f32> -> tensor<?x3x?x?xf32>
// CHECK:           %none = torch.constant.none
// CHECK:           %[[VAL_2:.*]] = mhlo.constant dense<0.000000e+00> : tensor<3xf32>
// CHECK:           %[[VAL_3:.*]] = mhlo.constant dense<1.000000e+00> : tensor<3xf32>
// CHECK:           %true = torch.constant.bool true
// CHECK:           %float1.000000e-01 = torch.constant.float 1.000000e-01
// CHECK:           %float1.000000e-05 = torch.constant.float 1.000000e-05
// CHECK:           %[[VAL_4:.*]] = arith.constant 1 : index
// CHECK:           %[[VAL_5:.*]] = tensor.dim %[[VAL_1]], %[[VAL_4]] : tensor<?x3x?x?xf32>
// CHECK:           %[[VAL_6:.*]] = tensor.from_elements %[[VAL_5]] : tensor<1xindex>
// CHECK:           %[[VAL_7:.*]] = mhlo.constant dense<1.000000e+00> : tensor<f32>
// CHECK:           %[[VAL_8:.*]] = "mhlo.dynamic_broadcast_in_dim"(%[[VAL_7]], %[[VAL_6]]) {broadcast_dimensions = dense<> : tensor<0xi64>} : (tensor<f32>, tensor<1xindex>) -> tensor<3xf32>
// CHECK:           %[[VAL_9:.*]] = mhlo.constant dense<0.000000e+00> : tensor<f32>
// CHECK:           %[[VAL_10:.*]] = "mhlo.dynamic_broadcast_in_dim"(%[[VAL_9]], %[[VAL_6]]) {broadcast_dimensions = dense<> : tensor<0xi64>} : (tensor<f32>, tensor<1xindex>) -> tensor<3xf32>
// CHECK:           %[[VAL_11:.*]], %[[VAL_12:.*]], %[[VAL_13:.*]] = "mhlo.batch_norm_training"(%[[VAL_1]], %[[VAL_8]], %[[VAL_10]]) {epsilon = 9.99999974E-6 : f32, feature_index = 1 : i64} : (tensor<?x3x?x?xf32>, tensor<3xf32>, tensor<3xf32>) -> (tensor<?x3x?x?xf32>, tensor<3xf32>, tensor<3xf32>)
// CHECK:           %[[VAL_14:.*]] = torch_c.from_builtin_tensor %[[VAL_11]] : tensor<?x3x?x?xf32> -> !torch.vtensor<[?,3,?,?],f32>
// CHECK:           return %[[VAL_14]] : !torch.vtensor<[?,3,?,?],f32>
func.func @torch.aten.batch_norm$no_bias_weight(%arg0: !torch.vtensor<[?,3,?,?],f32>) -> !torch.vtensor<[?,3,?,?],f32> {
  %none = torch.constant.none
  %0 = torch.vtensor.literal(dense<0.000000e+00> : tensor<3xf32>) : !torch.vtensor<[3],f32>
  %1 = torch.vtensor.literal(dense<1.000000e+00> : tensor<3xf32>) : !torch.vtensor<[3],f32>
  %true = torch.constant.bool true
  %float1.000000e-01 = torch.constant.float 1.000000e-01
  %float1.000000e-05 = torch.constant.float 1.000000e-05
  %2 = torch.aten.batch_norm %arg0, %none, %none, %0, %1, %true, %float1.000000e-01, %float1.000000e-05, %true : !torch.vtensor<[?,3,?,?],f32>, !torch.none, !torch.none, !torch.vtensor<[3],f32>, !torch.vtensor<[3],f32>, !torch.bool, !torch.float, !torch.float, !torch.bool -> !torch.vtensor<[?,3,?,?],f32>
  return %2 : !torch.vtensor<[?,3,?,?],f32>
}


// CHECK-LABEL:   func @torch.aten.native_layer_norm(
// CHECK-SAME:                                       %[[VAL_0:.*]]: !torch.vtensor<[3,7,4,5],f32>) -> !torch.vtensor<[3,7,4,5],f32> {
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[3,7,4,5],f32> -> tensor<3x7x4x5xf32>
// CHECK:           %[[VAL_2:.*]] = mhlo.constant dense<0.000000e+00> : tensor<4x5xf32>
// CHECK:           %[[VAL_3:.*]] = mhlo.constant dense<1.000000e+00> : tensor<4x5xf32>
// CHECK:           %int4 = torch.constant.int 4
// CHECK:           %int5 = torch.constant.int 5
// CHECK:           %float1.000000e-05 = torch.constant.float 1.000000e-05
// CHECK:           %true = torch.constant.bool true
// CHECK:           %[[VAL_4:.*]] = torch.prim.ListConstruct %int4, %int5 : (!torch.int, !torch.int) -> !torch.list<int>
// CHECK:           %[[VAL_5:.*]] = mhlo.constant dense<[1, 21, 20]> : tensor<3xi64>
// CHECK:           %[[VAL_6:.*]] = mhlo.dynamic_reshape %[[VAL_1]], %[[VAL_5]] : (tensor<3x7x4x5xf32>, tensor<3xi64>) -> tensor<1x21x20xf32>
// CHECK:           %[[VAL_7:.*]] = mhlo.constant dense<1.000000e+00> : tensor<21xf32>
// CHECK:           %[[VAL_8:.*]] = mhlo.constant dense<0.000000e+00> : tensor<21xf32>
// CHECK:           %[[VAL_9:.*]], %[[VAL_10:.*]], %[[VAL_11:.*]] = "mhlo.batch_norm_training"(%[[VAL_6]], %[[VAL_7]], %[[VAL_8]]) {epsilon = 9.99999974E-6 : f32, feature_index = 1 : i64} : (tensor<1x21x20xf32>, tensor<21xf32>, tensor<21xf32>) -> (tensor<1x21x20xf32>, tensor<21xf32>, tensor<21xf32>)
// CHECK:           %[[VAL_12:.*]] = mhlo.constant dense<[3, 7, 4, 5]> : tensor<4xi64>
// CHECK:           %[[VAL_13:.*]] = mhlo.dynamic_reshape %[[VAL_9]], %[[VAL_12]] : (tensor<1x21x20xf32>, tensor<4xi64>) -> tensor<3x7x4x5xf32>
// CHECK:           %[[VAL_14:.*]] = mhlo.constant dense<[3, 7, 1, 1]> : tensor<4xi64>
// CHECK:           %[[VAL_15:.*]] = mhlo.dynamic_reshape %[[VAL_10]], %[[VAL_14]] : (tensor<21xf32>, tensor<4xi64>) -> tensor<3x7x1x1xf32>
// CHECK:           %[[VAL_16:.*]] = mhlo.constant dense<[3, 7, 1, 1]> : tensor<4xi64>
// CHECK:           %[[VAL_17:.*]] = mhlo.dynamic_reshape %[[VAL_11]], %[[VAL_16]] : (tensor<21xf32>, tensor<4xi64>) -> tensor<3x7x1x1xf32>
// CHECK:           %[[VAL_18:.*]] = "mhlo.broadcast_in_dim"(%[[VAL_3]]) {broadcast_dimensions = dense<[2, 3]> : tensor<2xi64>} : (tensor<4x5xf32>) -> tensor<3x7x4x5xf32>
// CHECK:           %[[VAL_19:.*]] = "mhlo.broadcast_in_dim"(%[[VAL_2]]) {broadcast_dimensions = dense<[2, 3]> : tensor<2xi64>} : (tensor<4x5xf32>) -> tensor<3x7x4x5xf32>
// CHECK:           %[[VAL_20:.*]] = mhlo.multiply %[[VAL_13]], %[[VAL_18]] : tensor<3x7x4x5xf32>
// CHECK:           %[[VAL_21:.*]] = mhlo.add %[[VAL_20]], %[[VAL_19]] : tensor<3x7x4x5xf32>
// CHECK:           %[[VAL_22:.*]] = torch_c.from_builtin_tensor %[[VAL_21:.*]] : tensor<3x7x4x5xf32> -> !torch.vtensor<[3,7,4,5],f32>
// CHECK:           return %[[VAL_22]] : !torch.vtensor<[3,7,4,5],f32>
func.func @torch.aten.native_layer_norm(%arg0: !torch.vtensor<[3,7,4,5],f32>) -> !torch.vtensor<[3,7,4,5],f32> {
  %0 = torch.vtensor.literal(dense<0.000000e+00> : tensor<4x5xf32>) : !torch.vtensor<[4,5],f32>
  %1 = torch.vtensor.literal(dense<1.000000e+00> : tensor<4x5xf32>) : !torch.vtensor<[4,5],f32>
  %int4 = torch.constant.int 4
  %int5 = torch.constant.int 5
  %float1.000000e-05 = torch.constant.float 1.000000e-05
  %true = torch.constant.bool true
  %2 = torch.prim.ListConstruct %int4, %int5 : (!torch.int, !torch.int) -> !torch.list<int>
  %result0, %result1, %result2 = torch.aten.native_layer_norm %arg0, %2, %1, %0, %float1.000000e-05 : !torch.vtensor<[3,7,4,5],f32>, !torch.list<int>, !torch.vtensor<[4,5],f32>, !torch.vtensor<[4,5],f32>, !torch.float -> !torch.vtensor<[3,7,4,5],f32>, !torch.vtensor<[3,7,1,1],f32>, !torch.vtensor<[3,7,1,1],f32>
  return %result0 : !torch.vtensor<[3,7,4,5],f32>
}

// -----


// CHECK-LABEL:  func.func @torch.aten.cat$convert(
// CHECK-SAME:         %[[ARG0:.*]]: !torch.vtensor<[?,?],f32>, %[[ARG1:.*]]: !torch.vtensor<[?,?],si32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:         %[[INT0:.*]] = torch.constant.int 0
// CHECK:         %[[T0:.*]] = torch.prim.ListConstruct %[[ARG0]], %[[ARG1]] : (!torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],si32>) -> !torch.list<vtensor>
// CHECK:         %[[T1:.*]] = torch_c.to_builtin_tensor %[[ARG0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:         %[[T2:.*]] = torch_c.to_builtin_tensor %[[ARG1]] : !torch.vtensor<[?,?],si32> -> tensor<?x?xi32>
// CHECK:         %[[T3:.*]] = mhlo.convert %[[T2]] : (tensor<?x?xi32>) -> tensor<?x?xf32>
// CHECK:         %[[T4:.*]] = "mhlo.concatenate"(%[[T1]], %[[T3]]) {dimension = 0 : i64} : (tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK:         %[[T5:.*]] = torch_c.from_builtin_tensor %[[T4]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:         return %[[T5]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.cat$convert(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?,?],si32>) -> !torch.vtensor<[?,?],f32> {
  %int0 = torch.constant.int 0
  %0 = torch.prim.ListConstruct %arg0, %arg1 : (!torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],si32>) -> !torch.list<vtensor>
  %1 = torch.aten.cat %0, %int0 : !torch.list<vtensor>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %1 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.cat(
// CHECK-SAME:                              %[[ARG_0:.*]]: !torch.vtensor<[?,?],f32>, 
// CHECK-SAME:                              %[[ARG_1:.*]]: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
// CHECK:           %int0 = torch.constant.int 0
// CHECK:           %[[VAL_0:.*]] = torch.prim.ListConstruct %[[ARG_0]], %[[ARG_1]] : (!torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],f32>) -> !torch.list<vtensor>
// CHECK:           %[[VAL_1:.*]] = torch_c.to_builtin_tensor %[[ARG_0]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:           %[[VAL_2:.*]] = torch_c.to_builtin_tensor %[[ARG_1]] : !torch.vtensor<[?,?],f32> -> tensor<?x?xf32>
// CHECK:           %[[VAL_3:.*]] = "mhlo.concatenate"(%[[VAL_1]], %[[VAL_2]]) {dimension = 0 : i64} : (tensor<?x?xf32>, tensor<?x?xf32>) -> tensor<?x?xf32>
// CHECK:           %[[VAL_4:.*]] = torch_c.from_builtin_tensor %[[VAL_3]] : tensor<?x?xf32> -> !torch.vtensor<[?,?],f32>
// CHECK:           return %[[VAL_4]] : !torch.vtensor<[?,?],f32>
func.func @torch.aten.cat(%arg0: !torch.vtensor<[?,?],f32>, %arg1: !torch.vtensor<[?,?],f32>) -> !torch.vtensor<[?,?],f32> {
  %int0 = torch.constant.int 0
  %0 = torch.prim.ListConstruct %arg0, %arg1 : (!torch.vtensor<[?,?],f32>, !torch.vtensor<[?,?],f32>) -> !torch.list<vtensor>
  %1 = torch.aten.cat %0, %int0 : !torch.list<vtensor>, !torch.int -> !torch.vtensor<[?,?],f32>
  return %1 : !torch.vtensor<[?,?],f32>
}

// -----

// CHECK-LABEL:   func.func @torch.aten.gelu_backward(
// CHECK-SAME:                       %[[VAL_0:.*]]: !torch.vtensor<[5,3],f32>,
// CHECK-SAME:                       %[[VAL_1:.*]]: !torch.vtensor<[5,3],f32>) -> !torch.vtensor<[5,3],f32> {
// CHECK:           %[[VAL_2:.*]] = torch_c.to_builtin_tensor %[[VAL_0]] : !torch.vtensor<[5,3],f32> -> tensor<5x3xf32>
// CHECK:           %[[VAL_3:.*]] = torch_c.to_builtin_tensor %[[VAL_1]] : !torch.vtensor<[5,3],f32> -> tensor<5x3xf32>
// CHECK:           %[[VAL_4:.*]] = torch.constant.str "none"
// CHECK:           %[[VAL_5:.*]] = "chlo.constant_like"(%[[VAL_3]]) {value = 0.707106769 : f32} : (tensor<5x3xf32>) -> tensor<5x3xf32>
// CHECK:           %[[VAL_6:.*]] = "chlo.constant_like"(%[[VAL_3]]) {value = 1.12837923 : f32} : (tensor<5x3xf32>) -> tensor<5x3xf32>
// CHECK:           %[[VAL_7:.*]] = "chlo.constant_like"(%[[VAL_3]]) {value = 5.000000e-01 : f32} : (tensor<5x3xf32>) -> tensor<5x3xf32>
// CHECK:           %[[VAL_8:.*]] = "chlo.constant_like"(%[[VAL_3]]) {value = 1.000000e+00 : f32} : (tensor<5x3xf32>) -> tensor<5x3xf32>
// CHECK:           %[[VAL_9:.*]] = "chlo.constant_like"(%[[VAL_3]]) {value = -5.000000e-01 : f32} : (tensor<5x3xf32>) -> tensor<5x3xf32>
// CHECK:           %[[VAL_10:.*]] = mhlo.multiply %[[VAL_5]], %[[VAL_6]] : tensor<5x3xf32>
// CHECK:           %[[VAL_11:.*]] = mhlo.multiply %[[VAL_10]], %[[VAL_7]] : tensor<5x3xf32>
// CHECK:           %[[VAL_12:.*]] = mhlo.multiply %[[VAL_5]], %[[VAL_3]] : tensor<5x3xf32>
// CHECK:           %[[VAL_13:.*]] = chlo.erf %[[VAL_12]] : tensor<5x3xf32> -> tensor<5x3xf32>
// CHECK:           %[[VAL_14:.*]] = mhlo.add %[[VAL_13]], %[[VAL_8]] : tensor<5x3xf32>
// CHECK:           %[[VAL_15:.*]] = mhlo.multiply %[[VAL_14]], %[[VAL_7]] : tensor<5x3xf32>
// CHECK:           %[[VAL_16:.*]] = mhlo.multiply %[[VAL_3]], %[[VAL_3]] : tensor<5x3xf32>
// CHECK:           %[[VAL_17:.*]] = mhlo.multiply %[[VAL_16]], %[[VAL_9]] : tensor<5x3xf32>
// CHECK:           %[[VAL_18:.*]] = mhlo.exponential %[[VAL_17]] : tensor<5x3xf32>
// CHECK:           %[[VAL_19:.*]] = mhlo.multiply %[[VAL_11]], %[[VAL_18]] : tensor<5x3xf32>
// CHECK:           %[[VAL_20:.*]] = mhlo.multiply %[[VAL_19]], %[[VAL_3]] : tensor<5x3xf32>
// CHECK:           %[[VAL_21:.*]] = mhlo.add %[[VAL_20]], %[[VAL_15]] : tensor<5x3xf32>
// CHECK:           %[[VAL_22:.*]] = mhlo.multiply %[[VAL_2]], %[[VAL_21]] : tensor<5x3xf32>
// CHECK:           %[[VAL_23:.*]] = torch_c.from_builtin_tensor %[[VAL_22]] : tensor<5x3xf32> -> !torch.vtensor<[5,3],f32>
// CHECK:           return %[[VAL_23]] : !torch.vtensor<[5,3],f32>
// CHECK:         }
func.func @torch.aten.gelu_backward(%arg0: !torch.vtensor<[5,3],f32>, %arg1: !torch.vtensor<[5,3],f32>) -> !torch.vtensor<[5,3],f32> {
    %str = torch.constant.str "none"
    %0 = torch.aten.gelu_backward %arg0, %arg1, %str : !torch.vtensor<[5,3],f32>, !torch.vtensor<[5,3],f32>, !torch.str -> !torch.vtensor<[5,3],f32>
    return %0 : !torch.vtensor<[5,3],f32>
  }