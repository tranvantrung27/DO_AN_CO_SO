import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setErrorState('Không tìm thấy camera');
        return;
      }

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      // Kiểm tra nếu component vẫn mounted sau khi khởi tạo camera
      if (mounted) {
        setState(() {
        });
      }
    } catch (e) {
      _setErrorState('Không thể khởi tạo camera: $e');
    }
  }

  void _setErrorState(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _setErrorState('Camera chưa sẵn sàng');
      return;
    }

    try {
      // Thêm hiệu ứng flash hoặc feedback cho người dùng
      setState(() {});

      final image = await _controller!.takePicture();
      
      if (mounted) {
        // Xử lý ảnh đã chụp - ví dụ: hiển thị trên màn hình khác
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã chụp ảnh: ${image.path}')),
        );
        
        // Ở đây bạn có thể chuyển hướng đến màn hình xem trước ảnh
        // Navigator.of(context).push(...);
      }
    } catch (e) {
      _setErrorState('Lỗi khi chụp ảnh: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét tài liệu'),
        backgroundColor: Colors.black.withOpacity(0.5),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (_errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = '';
                        _initializeControllerFuture = _initializeCamera();
                      });
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done && 
              _controller != null && 
              _controller!.value.isInitialized) {
            
            return Stack(
              fit: StackFit.expand,
              children: [
                // Camera Preview với các điều chỉnh cho tỷ lệ khung hình
                _buildCameraPreview(),
                
                // Overlay frame for document scanning
                _buildScanOverlay(),
                
                // Controls at the bottom
                _buildControlsOverlay(),
              ],
            );
          } else {
            // Đang tải
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang khởi tạo camera...'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller == null) return Container();
    
    // Cải thiện việc xử lý tỷ lệ khung hình
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final cameraRatio = _controller!.value.aspectRatio;
    
    // Xác định scale để điều chỉnh preview cho phù hợp với màn hình
    var scale = 1.0;
    if (deviceRatio < cameraRatio) {
      scale = size.height / (size.width / cameraRatio);
    } else {
      scale = size.width / (size.height * cameraRatio);
    }
    
    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8 * (4/3), // Tỷ lệ khung A4
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
  final bottomPadding = MediaQuery.of(context).padding.bottom;

  return Positioned(
    bottom: bottomPadding + 100, // đẩy nút lên một chút
    left: 0,
    right: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Nút chụp ảnh
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.8),
          ),
          child: IconButton(
            icon: const Icon(Icons.camera_alt, size: 36),
            color: Colors.black,
            onPressed: _takePicture,
          ),
        ),

        // Nút flash
        FloatingActionButton(
          heroTag: 'toggleFlash',
          mini: true,
          backgroundColor: Colors.white.withOpacity(0.8),
          child: Icon(
            _controller?.value.flashMode == FlashMode.torch
                ? Icons.flash_off
                : Icons.flash_on,
            color: Colors.amber.shade800,
          ),
          onPressed: () {
            if (_controller != null) {
              final newFlashMode = _controller!.value.flashMode == FlashMode.off
                  ? FlashMode.torch
                  : FlashMode.off;
              _controller!.setFlashMode(newFlashMode);
              setState(() {});
            }
          },
        ),
      ],
    ),
  );
}
}