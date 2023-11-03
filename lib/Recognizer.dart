library thirteen3_face_attendance;
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'Recognition.dart';

class Recognizer {
  static Map<String, Map<String, Recognition>> registered = {};
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;

  late var _probabilityProcessor;

  @override
  String get modelName => 'facenet.tflite';

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 1);


  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();
    _interpreterOptions.useNnApiForAndroid = true;
    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter =
      await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      print('Interpreter Created Successfully');
      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(postProcessNormalizeOp).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
        _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  Recognition recognize(Image image,Rect location) {
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
     _probabilityProcessor.process(_outputBuffer);
    //     .getMapWithFloatValue();
    // final pred = getTopProbability(labeledProb);
    Pair pair = findNearestMatch(_outputBuffer.getDoubleList());
    return Recognition(pair.id,pair.name,pair.image, _outputBuffer.getDoubleList(),pair.distance);
  }

  List<double> register(Image image,Rect location) {
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    _probabilityProcessor.process(_outputBuffer);
    //     .getMapWithFloatValue();
    // final pred = getTopProbability(labeledProb);
    // Pair pair = findNearest(_outputBuffer.getDoubleList());
    return _outputBuffer.getDoubleList();
  }

  //TODO  looks for the nearest embeeding in the dataset
  // and retrurns the pair <id, distance>
  // findNearest(List<double> emb){
  //   Pair pair = Pair("Unknown",'','', -5);
  //   for (MapEntry<String, Map<String,Recognition>> item in RecognitionScreen.registered.entries) {
  //     final String name = item.value.keys.toList()[0];
  //     List<double> knownEmb = item.value.values.toList()[0].embeddings;
  //     double distance = 0;
  //     for (int i = 0; i < emb.length; i++) {
  //       double diff = emb[i] - knownEmb[i];
  //       distance += diff*diff;
  //     }
  //     distance = sqrt(distance);
  //     if (pair.distance == -5 || distance < pair.distance) {
  //       pair.distance = distance;
  //       pair.name = name;
  //       pair.id = item.key;
  //       pair.image = item.value.values.toList()[0].image;
  //     }
  //   }
  //   return pair;
  // }

  Pair findNearestMatch(List<double> emb) {
    Pair pair = Pair("Unknown", '', '', double.infinity); // Initialize with +infinity
    for (var entry in registered.entries) {
      final String name = entry.value.keys.first;
      List<double> knownEmb = entry.value.values.first.embeddings;
      double distance = calculateDistance(emb, knownEmb);
      if (distance < pair.distance) {
        pair.distance = distance;
        pair.name = name;
        pair.id = entry.key;
        pair.image = entry.value.values.first.image;
      }
    }
    return pair;
  }

  double calculateDistance(List<double> emb1, List<double> emb2) {
    double distance = 0;
    for (int i = 0; i < emb1.length; i++) {
      double diff = emb1[i] - emb2[i];
      distance += diff * diff;
    }
    return sqrt(distance);
  }


  void close() {
    interpreter.close();
  }

}
class Pair{
   String name;
   double distance;
   String id;
   String image;
   Pair(this.name,this.id,this.image,this.distance);
}


