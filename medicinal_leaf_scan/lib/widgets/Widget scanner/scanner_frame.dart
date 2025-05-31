import 'package:flutter/material.dart';

// Widget scanner frame nâng cao - phiên bản cải thiện
class ScannerFrame extends StatelessWidget {
  final Widget child;
  final Animation<double> scanAnimation;
  final bool showOverlay; // Tùy chọn hiển thị overlay
  
  const ScannerFrame({
    Key? key,
    required this.child,
    required this.scanAnimation,
    this.showOverlay = true,
  }) : super(key: key);

  Widget _buildCorner({
    required bool isTop,
    required bool isLeft,
    required double size,
  }) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: isTop 
              ? BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
            bottom: !isTop 
              ? BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
            left: isLeft 
              ? BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
            right: !isLeft 
              ? BorderSide(color: Colors.greenAccent, width: 3)
              : BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.8;
    
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Nội dung chính (hình ảnh) - đảm bảo fill toàn bộ container
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: child,
            ),
          ),
          
          // Overlay gradient nhẹ - chỉ hiển thị khi cần
          if (showOverlay)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          
          // 4 góc scanner với hiệu ứng phát sáng
          ...[
            _buildCorner(isTop: true, isLeft: true, size: 30),
            _buildCorner(isTop: true, isLeft: false, size: 30),
            _buildCorner(isTop: false, isLeft: true, size: 30),
            _buildCorner(isTop: false, isLeft: false, size: 30),
          ],
          
          // Hiệu ứng glow cho góc
          ...[
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -5,
              left: -5,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -5,
              right: -5,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
          
          // Thanh quét với hiệu ứng đẹp hơn
          AnimatedBuilder(
            animation: scanAnimation,
            builder: (context, child) {
              final scanPosition = scanAnimation.value * size;
              return Positioned(
                top: scanPosition - 1,
                left: 10,
                right: 10,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.greenAccent.withOpacity(0.4),
                        Colors.greenAccent.withOpacity(0.8),
                        Colors.greenAccent,
                        Colors.greenAccent.withOpacity(0.8),
                        Colors.greenAccent.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Đường viền mờ xung quanh
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.greenAccent.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}