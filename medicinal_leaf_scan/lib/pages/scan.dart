import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:medicinal_leaf_scan/pages/nhandien/detection_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  String _errorMessage = '';
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) setState(() {});
    } catch (e) {
      _setErrorState('Không thể khởi tạo camera');
    }
  }

  void _setErrorState(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final File imageFile = File(pickedFile.path);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionScreen(imageFile: imageFile),
          ),
        ).then((_) {
          if (mounted) setState(() => _isProcessing = false);
        });
      }
    } catch (e) {
      _setErrorState('Lỗi khi chọn ảnh');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void capturePhoto() {
    _takePicture();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _setErrorState('Camera chưa sẵn sàng');
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      final image = await _controller!.takePicture();
      final File imageFile = File(image.path);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetectionScreen(imageFile: imageFile),
          ),
        ).then((_) {
          if (mounted) setState(() => _isProcessing = false);
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _setErrorState('Lỗi khi chụp ảnh');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive values
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final isLandscape = screenSize.width > screenSize.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Quét lá thuốc',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 24 : 20, // Responsive font size
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (_errorMessage.isNotEmpty) {
            return _buildErrorState(isTablet);
          }

          if (snapshot.connectionState == ConnectionState.done && 
              _controller != null && 
              _controller!.value.isInitialized) {
            return _buildCameraView(context, screenSize, isTablet, isLandscape, bottomPadding, topPadding);
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  Widget _buildErrorState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline, 
              color: Colors.red, 
              size: isTablet ? 80 : 60,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16, 
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                  _initializeControllerFuture = _initializeCamera();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appBarColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: isTablet ? 16 : 12,
                ),
              ),
              child: Text(
                'Thử lại',
                style: TextStyle(fontSize: isTablet ? 18 : 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildCameraView(BuildContext context, Size screenSize, bool isTablet, 
                         bool isLandscape, double bottomPadding, double topPadding) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview với tap to capture
        GestureDetector(
          onTap: _isProcessing ? null : _takePicture,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildCameraPreview(context),
              );
            },
          ),
        ),
        
        // Scan overlay
        _buildScanOverlay(context, screenSize, isTablet, isLandscape),
        
        // Processing overlay
        _buildProcessingOverlay(isTablet),
        
        // Top controls
        _buildTopControls(topPadding, isTablet, isLandscape),
        
        // Bottom controls
        _buildBottomControls(context, screenSize, isTablet, isLandscape, bottomPadding),
        
        // Instruction text
        _buildInstructionText(screenSize, isTablet, bottomPadding),
      ],
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) return Container();

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final cameraRatio = _controller!.value.aspectRatio;

    bool isFrontCamera = _controller!.description.lensDirection == CameraLensDirection.front;

    return ClipRect(
      child: OverflowBox(
        maxWidth: deviceRatio > cameraRatio ? size.width : size.height * cameraRatio,
        maxHeight: deviceRatio > cameraRatio ? size.width / cameraRatio : size.height,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(isFrontCamera ? -1.0 : 1.0, 1.0, 1.0),
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context, Size screenSize, bool isTablet, bool isLandscape) {
    // Responsive overlay size
    double overlayWidth;
    double overlayHeight;
    
    if (isTablet) {
      overlayWidth = isLandscape ? screenSize.width * 0.5 : screenSize.width * 0.7;
    } else {
      overlayWidth = screenSize.width * 0.8;
    }
    
    overlayHeight = overlayWidth * (4 / 3);

    return Center(
      child: Container(
        width: overlayWidth,
        height: overlayHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
          border: Border.all(
            color: Colors.white.withOpacity(0.9), 
            width: isTablet ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: isTablet ? 20 : 16,
              spreadRadius: isTablet ? 3 : 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Corner decorations
            ...List.generate(4, (index) {
              final cornerSize = isTablet ? 40.0 : 30.0;
              final borderWidth = isTablet ? 5.0 : 4.0;
              
              return Positioned(
                top: index < 2 ? 10 : null,
                bottom: index >= 2 ? 10 : null,
                left: index % 2 == 0 ? 10 : null,
                right: index % 2 == 1 ? 10 : null,
                child: Container(
                  width: cornerSize,
                  height: cornerSize,
                  decoration: BoxDecoration(
                    border: Border(
                      top: index < 2 ? BorderSide(color: Colors.white, width: borderWidth) : BorderSide.none,
                      bottom: index >= 2 ? BorderSide(color: Colors.white, width: borderWidth) : BorderSide.none,
                      left: index % 2 == 0 ? BorderSide(color: Colors.white, width: borderWidth) : BorderSide.none,
                      right: index % 2 == 1 ? BorderSide(color: Colors.white, width: borderWidth) : BorderSide.none,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay(bool isTablet) {
    return AnimatedOpacity(
      opacity: _isProcessing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: isTablet ? 60 : 40,
                height: isTablet ? 60 : 40,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                'Đang xử lý...',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: isTablet ? 20 : 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls(double topPadding, bool isTablet, bool isLandscape) {
    return Positioned(
      top: topPadding + 20,
      right: 20,
      child: _buildFlashButton(isTablet),
    );
  }

  Widget _buildFlashButton(bool isTablet) {
    final isFlashSupported = _controller?.value.flashMode != null;
    
    if (!isFlashSupported) return const SizedBox();

    final buttonSize = isTablet ? 35.0 : 28.0;
    final containerSize = isTablet ? 60.0 : 50.0;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(containerSize / 2),
      ),
      child: IconButton(
        icon: Icon(
          _controller?.value.flashMode == FlashMode.torch
              ? Icons.flash_off
              : Icons.flash_on,
          color: _controller?.value.flashMode == FlashMode.torch
              ? Colors.amber
              : Colors.white,
          size: buttonSize,
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
    );
  }

  Widget _buildBottomControls(BuildContext context, Size screenSize, bool isTablet, 
                             bool isLandscape, double bottomPadding) {
    final buttonSize = isTablet ? 35.0 : 28.0;
    final containerSize = isTablet ? 60.0 : 50.0;
    final bottomOffset = isTablet ? 120.0 : 100.0;

    return Positioned(
      bottom: bottomPadding + bottomOffset,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
        child: Row(
          mainAxisAlignment: isLandscape 
              ? MainAxisAlignment.spaceEvenly 
              : MainAxisAlignment.start,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(containerSize / 2),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.photo_library,
                  color: Colors.white, 
                  size: buttonSize,
                ),
                onPressed: _isProcessing ? null : _pickImageFromGallery,
              ),
            ),
            
            // Capture button (thêm nút chụp lớn ở giữa cho tablet)
            if (isTablet) ...[
              SizedBox(width: 40),
              GestureDetector(
                onTap: _isProcessing ? null : _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionText(Size screenSize, bool isTablet, double bottomPadding) {
    final bottomOffset = isTablet ? 200.0 : 170.0;
    
    return Positioned(
      bottom: bottomPadding + bottomOffset,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),

      ),
    );
  }
}