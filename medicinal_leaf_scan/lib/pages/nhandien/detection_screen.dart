import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/services/leaf_recognition_service.dart';
import '../../widgets/Widget scanner/scanner_frame.dart';
import 'ketqua/result_screen.dart';
import 'package:lottie/lottie.dart';


class DetectionScreen extends StatefulWidget {
  final File imageFile;

  const DetectionScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

// Thêm TickerProviderStateMixin cho animation
class _DetectionScreenState extends State<DetectionScreen> with TickerProviderStateMixin {
  // Biến trạng thái cho các bước
  bool _step1Loading = false;
  bool _step2Loading = false;
  bool _step3Loading = false;

  bool _step1Complete = false;
  bool _step2Complete = false;
  bool _step3Complete = false;

  // Biến để kiểm soát hiển thị các bước
  bool _showStep1 = false;
  bool _showStep2 = false;
  bool _showStep3 = false;

  // Animation controller cho thanh quét
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  final LeafRecognitionService _recognitionService = LeafRecognitionService();
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo animation cho thanh quét
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ));
    
    // Bắt đầu quá trình nhận diện
    _startDetectionProcess();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

Future<void> _startDetectionProcess() async {
  try {
    await _recognitionService.loadModel();

    setState(() {
      _showStep1 = true;
      _step1Loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 3300));

    setState(() {
      _step1Loading = false;
      _step1Complete = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _showStep2 = true;
      _step2Loading = true;
    });

    _result = await _recognitionService.recognizeLeaf(widget.imageFile);

    if (_result != null && _result!.containsKey('error')) {
      throw Exception(_result!['error']);
    }

    // Kiểm tra nếu class_index là 30 hoặc -1, lập tức báo lỗi
    final int classIndex = _result!['class_index'] ?? -1;

    if (classIndex == 30 || classIndex == -1) {
      // Dừng loading, ẩn step 2, show dialog lỗi và quay lại trang trước
      setState(() {
        _step2Loading = false;
        _step2Complete = false;
        _showStep2 = false; // Ẩn step 2 luôn
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi nhận dạng'),
          content: const Text('Hình ảnh không phải là lá thuốc hoặc không nhận diện được. Vui lòng thử lại với ảnh khác.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại màn hình trước
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return; // Dừng tiếp tục các bước sau
    }

    await Future.delayed(const Duration(milliseconds: 2500));

    setState(() {
      _step2Loading = false;
      _step2Complete = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _showStep3 = true;
      _step3Loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 5000));

    setState(() {
      _step3Loading = false;
      _step3Complete = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted && _result != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imageFile: widget.imageFile,
            recognitionResult: _result!,
          ),
        ),
      );
    }
  } catch (e) {
    print('Lỗi trong quá trình nhận diện: $e');
    if (mounted) {
      setState(() {
        _step1Loading = false;
        _step2Loading = false;
        _step3Loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}




  // Hàm helper để hiển thị icon phù hợp theo trạng thái
  Widget _getStepIcon(bool isLoading, bool isComplete) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Color(0xFF4CAF50),
          strokeWidth: 2.5,
        ),
      );
    } else if (isComplete) {
      return const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24);
    } else {
      return const Icon(
        Icons.circle_outlined,
        color: Color(0xFF4CAF50),
        size: 24,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final frameSize = screenSize.width * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFF4A4A4A),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),


// Thay thế phần build ScannerFrame trong DetectionScreen

// Sử dụng ScannerFrame với Container để đảm bảo fit nguyên ảnh
ScannerFrame(
  scanAnimation: _scanAnimation,
  child: Container(
    width: frameSize,
    height: frameSize,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      color: Colors.black, // Màu nền cho vùng trống
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.file(
        widget.imageFile,
        fit: BoxFit.contain, // Thay đổi từ cover thành contain
        width: frameSize,
        height: frameSize,
      ),
    ),
  ),
),
            const SizedBox(height: 20),
            const SizedBox(height: 15),

            // Animation loading với Lottie
            SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset(
                'assets/load/load.json',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),
            
            // Text "Đang Quét..."
            const Text(
              'Đang Quét...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Text mô tả
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Đang tìm kiếm dữ liệu về lá thuốc trong hệ thống.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const Spacer(flex: 1),

            // Các bước với checkbox và hiệu ứng loading
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bước 1: Chỉ hiển thị khi _showStep1 = true
                  if (_showStep1)
                    Row(
                      children: [
                        _getStepIcon(_step1Loading, _step1Complete),
                        const SizedBox(width: 10),
                        const Text(
                          'Đang lấy thông tin...',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
 if (_showStep1) const SizedBox(height: 10),
                

                  // Bước 2: Chỉ hiển thị khi _showStep2 = true
                  if (_showStep2)
                    Row(
                      children: [
                        _getStepIcon(_step2Loading, _step2Complete),
                        const SizedBox(width: 10),
                        const Text(
                          'Lá thuốc đã được nhận dạng!!',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                  if (_showStep2) const SizedBox(height: 10),

                  // Bước 3: Chỉ hiển thị khi _showStep3 = true
                  if (_showStep3)
                    Row(
                      children: [
                        _getStepIcon(_step3Loading, _step3Complete),
                        const SizedBox(width: 10),
                        const Text(
                          'Sắp hoàn thành',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}