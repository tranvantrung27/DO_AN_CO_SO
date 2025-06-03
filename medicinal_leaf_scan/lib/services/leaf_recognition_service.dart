import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class LeafRecognitionService {
  bool _modelLoaded = false;
  Interpreter? _interpreter;
  // Cập nhật đường dẫn model và labels phù hợp với code gốc
  static const String MODEL_PATH = "assets/models/models.tflite";
  //static const String LABELS_PATH = "assets/models/labels.txt";

  // Kích thước input theo mô hình
  int _inputHeight = 224;
  int _inputWidth = 224;
  // Output shape list để lưu kết quả
  List<List<double>> _outputShapeList = [];

  Future<void> loadModel() async {
    try {
      // Tải labels
      // final labelsData = await rootBundle.loadString(LABELS_PATH);
      // _labels = labelsData.split('\n');
      // _labels = _labels.where((label) => label.trim().isNotEmpty).toList();
      // print('Đã tải ${_labels.length} labels: ${_labels.isNotEmpty ? _labels[0] : "none"}');

      // Tùy chọn cho TFLite Interpreter - sử dụng từ code gốc
      final options =
          InterpreterOptions()
            ..threads = 4
            ..useNnApiForAndroid = true; // Sử dụng Android Neural Networks API

      // Tải mô hình
      _interpreter = await Interpreter.fromAsset(MODEL_PATH, options: options);

      if (_interpreter == null) {
        throw Exception('Không thể tạo interpreter');
      }

      // Khởi tạo tensors
      _interpreter!.allocateTensors();

      // Lấy thông tin về input/output shape
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // Khởi tạo danh sách output với kích thước chính xác
      _outputShapeList = List.generate(
        outputShape[0],
        (_) => List.filled(outputShape[1], 0.0),
      );

      // Log thông tin tensor để debug
      print('Đã tải mô hình thành công');
      print('Input shape: $inputShape');
      print('Output shape: $outputShape');
      print(
        'Output shape list: ${_outputShapeList.length} x ${_outputShapeList[0].length}',
      );

      // Cập nhật kích thước input theo mô hình
      if (inputShape.length == 4) {
        _inputHeight = inputShape[1];
        _inputWidth = inputShape[2];
        print('Kích thước input: $_inputWidth x $_inputHeight');
      }

      _modelLoaded = true;
    } catch (e) {
      print('Lỗi khi tải mô hình: $e');
      throw Exception('Không thể tải mô hình: $e');
    }
  }

  // Trong leaf_recognition_service.dart, thêm hoặc điều chỉnh phương thức recognizeLeaf
  Future<Map<String, dynamic>> recognizeLeaf(File imageFile) async {
  if (!_modelLoaded || _interpreter == null) {
    await loadModel();
  }

  try {
    if (!imageFile.existsSync()) {
      return {'error': 'File ảnh không tồn tại'};
    }

    Uint8List imageBytes = await imageFile.readAsBytes();

    img.Image? rawImage = img.decodeImage(imageBytes);
    if (rawImage == null) {
      return {'error': 'Không thể decode hình ảnh'};
    }

    final resizedImage = img.copyResize(
      rawImage,
      width: _inputWidth,
      height: _inputHeight,
      interpolation: img.Interpolation.linear,
    );

    // Chuẩn bị input tensor 4 chiều (1, height, width, 3)
    var input = List.generate(
      1,
      (i) => List.generate(
        _inputHeight,
        (j) => List.generate(
          _inputWidth,
          (k) => List.generate(3, (l) => 0.0),
        ),
      ),
    );

    for (var y = 0; y < _inputHeight; y++) {
      for (var x = 0; x < _inputWidth; x++) {
        final pixel = resizedImage.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    // Reset output list
    for (int i = 0; i < _outputShapeList.length; i++) {
      for (int j = 0; j < _outputShapeList[i].length; j++) {
        _outputShapeList[i][j] = 0.0;
      }
    }

    _interpreter!.run(input, _outputShapeList);

    final outputVector = _outputShapeList[0];
    double maxScore = 0.0;
    int maxIndex = 0;

    for (int i = 0; i < outputVector.length; i++) {
      if (outputVector[i] > maxScore) {
        maxScore = outputVector[i];
        maxIndex = i;
      }
    }

    const double confidenceThreshold = 0.7; // Ngưỡng confidence để nhận dạng

    if (maxScore < confidenceThreshold) {
      // Confidence thấp: trả về không xác định
      return {
        'class_index': -1,
        'confidence': maxScore,
        'message': 'Không xác định được lá thuốc',
      };
    }

    print('Nhận nhãn từ mô hình: $maxIndex với confidence $maxScore');

    return {
      'class_index': maxIndex,
      'confidence': maxScore,
      'raw_output': outputVector,
    };
  } catch (e) {
    return {'error': 'Lỗi khi nhận dạng: $e'};
  }
}



  Future<void> dispose() async {
    try {
      if (_interpreter != null) {
        _interpreter!.close();
      }
      _modelLoaded = false;
      print('Đã giải phóng interpreter');
    } catch (e) {
      print('Lỗi khi giải phóng model: $e');
    }
  }
}
