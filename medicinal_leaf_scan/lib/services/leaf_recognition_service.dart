import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class LeafRecognitionService {
  bool _modelLoaded = false;
  Interpreter? _interpreter;
  // Cập nhật đường dẫn model và labels phù hợp với code gốc
  static const String MODEL_PATH = "assets/models/models.tflite";
  static const String LABELS_PATH = "assets/models/labels.txt";
  List<String> _labels = [];
  
  // Kích thước input theo mô hình
  int _inputHeight = 224;
  int _inputWidth = 224;
  // Output shape list để lưu kết quả
  List<List<double>> _outputShapeList = [];

  Future<void> loadModel() async {
    try {
      // Tải labels
      final labelsData = await rootBundle.loadString(LABELS_PATH);
      _labels = labelsData.split('\n');
      _labels = _labels.where((label) => label.trim().isNotEmpty).toList();
      print('Đã tải ${_labels.length} labels: ${_labels.isNotEmpty ? _labels[0] : "none"}');
      
      // Tùy chọn cho TFLite Interpreter - sử dụng từ code gốc
      final options = InterpreterOptions()
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
        (_) => List.filled(outputShape[1], 0.0)
      );
      
      // Log thông tin tensor để debug
      print('Đã tải mô hình thành công');
      print('Input shape: $inputShape');
      print('Output shape: $outputShape');
      print('Output shape list: ${_outputShapeList.length} x ${_outputShapeList[0].length}');
      
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
    try {
      await loadModel();
    } catch (e) {
      return {'error': 'Không thể tải mô hình: $e'};
    }
  }

  try {
    if (!imageFile.existsSync()) {
      return {'error': 'File ảnh không tồn tại'};
    }
    
    // Đọc và xử lý ảnh - sử dụng try-catch để bắt lỗi
    Uint8List imageBytes;
    try {
      imageBytes = await imageFile.readAsBytes();
    } catch (e) {
      return {'error': 'Không thể đọc ảnh: $e'};
    }
    
    img.Image? rawImage;
    try {
      rawImage = img.decodeImage(imageBytes);
    } catch (e) {
      return {'error': 'Không thể giải mã ảnh: $e'};
    }
    
    if (rawImage == null) {
      return {'error': 'Không thể decode hình ảnh'};
    }
    
    print('Đang resize ảnh về $_inputWidth x $_inputHeight');
    
    // Resize ảnh theo kích thước input của mô hình
    final resizedImage = img.copyResize(
      rawImage,
      width: _inputWidth,
      height: _inputHeight,
      interpolation: img.Interpolation.linear,
    );

    // Tạo ma trận 4D với xử lý lỗi
    try {
      var input = List.generate(
        1, // batch
        (i) => List.generate(
          _inputHeight, // height
          (j) => List.generate(
            _inputWidth, // width
            (k) => List.generate(3, (l) => 0.0), // channels
          ),
        ),
      );

      // Điền dữ liệu hình ảnh vào ma trận 4D và normalize về [0,1]
      for (var y = 0; y < _inputHeight; y++) {
        for (var x = 0; x < _inputWidth; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[0][y][x][0] = pixel.r / 255.0;
          input[0][y][x][1] = pixel.g / 255.0;
          input[0][y][x][2] = pixel.b / 255.0;
        }
      }
      
      // Reset output list để đảm bảo không có dữ liệu cũ
      for (int i = 0; i < _outputShapeList.length; i++) {
        for (int j = 0; j < _outputShapeList[i].length; j++) {
          _outputShapeList[i][j] = 0.0;
        }
      }
      
      print('Đang chạy inference...');
      
      // Chạy inference với xử lý lỗi
      try {
        _interpreter!.run(input, _outputShapeList);
      } catch (e) {
        return {'error': 'Lỗi khi chạy inference: $e'};
      }
      
      // Tìm lớp có xác suất cao nhất và top 3 kết quả
      var maxScore = 0.0;
      var maxIndex = 0;
      
      // Lấy các cặp (index, score) để sắp xếp
      var indexedOutput = <MapEntry<int, double>>[];
      
      // Trong _outputShapeList, chỉ có 1 phần tử ở chiều đầu tiên
      for (int i = 0; i < _outputShapeList[0].length; i++) {
        final score = _outputShapeList[0][i];
        indexedOutput.add(MapEntry(i, score));
        
        if (score > maxScore) {
          maxScore = score;
          maxIndex = i;
        }
      }
      
      // Sắp xếp để lấy top 3
      indexedOutput.sort((a, b) => b.value.compareTo(a.value));
      
      // Đảm bảo các index không vượt quá số lượng labels
      final labelIndex = maxIndex < _labels.length ? maxIndex : 0;
      
      // Tạo danh sách top 3 kết quả
      var results = indexedOutput.take(3).map((entry) {
        final idx = entry.key < _labels.length ? entry.key : 0;
        return {
          'label': _labels[idx],
          'confidence': entry.value.toString(),
        };
      }).toList();
      
      print('Kết quả phân loại:');
      print('Index: $maxIndex');
      print('Label: ${_labels[labelIndex]}');
      print('Độ tin cậy: ${maxScore * 100}%');
      
      // Trả về kết quả theo định dạng mong muốn
      return {
        'class': _labels[labelIndex],
        'confidence': maxScore,
        'results': results,
      };
    } catch (e) {
      print('Lỗi khi nhận dạng: $e');
      return {'error': 'Lỗi khi nhận dạng: $e'};
    }
  } catch (e) {
    print('Lỗi khi nhận dạng: $e');
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