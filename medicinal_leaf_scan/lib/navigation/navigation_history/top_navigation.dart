import 'package:flutter/material.dart';
import 'dart:math' as math;


class TopNavigation extends StatefulWidget {
  // Thêm các thuộc tính mới
  final int initialIndex;
  final Function(int) onIndexChanged;
  
  const TopNavigation({
    Key? key, 
    this.initialIndex = 0,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  _TopNavigationState createState() => _TopNavigationState();
}

class _TopNavigationState extends State<TopNavigation> with SingleTickerProviderStateMixin {
  late int _selectedOption;
  final List<String> options = ["Lịch sử", "Bộ sưu tập lá thuốc"];
  
  // Controllers for animations
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    // Khởi tạo _selectedOption từ initialIndex
    _selectedOption = widget.initialIndex;
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    )..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // Sửa hàm _onTap để không dùng Navigator.push nữa
  void _onTap(int index, TapDownDetails details) {
    if (_selectedOption != index) {
      setState(() {
        _selectedOption = index;
        _tapPosition = details.localPosition;
      });

      widget.onIndexChanged(index);


      _animationController?.reset();
      _animationController?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [],
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          bool isSelected = _selectedOption == index;
          return RadioOption(
            label: options[index],
            isSelected: isSelected,
            onTap: (details) => _onTap(index, details),
            animation: isSelected ? _scaleAnimation : null,
            tapPosition: isSelected ? _tapPosition : null,
          );
        }),
      ),
    );
  }
}

class RadioOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Function(TapDownDetails) onTap;
  final Animation<double>? animation;
  final Offset? tapPosition;

  const RadioOption({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.animation,
    this.tapPosition,
  }) : super(key: key);

  @override
  _RadioOptionState createState() => _RadioOptionState();
}

class _RadioOptionState extends State<RadioOption> with SingleTickerProviderStateMixin {
  // Không dùng late để tránh lỗi
  AnimationController? _rippleController;
  Animation<double>? _rippleAnimation;
  Animation<double>? _particlesAnimation;
  Animation<double>? _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller và animation
    _initAnimations();
  }
  
  void _initAnimations() {
    _rippleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.2, end: 2.5).animate(
      CurvedAnimation(
        parent: _rippleController!,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _particlesAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController!,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController!,
        curve: Interval(0.0, 1.0, curve: Curves.linear),
      ),
    )..addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  @override
  void didUpdateWidget(RadioOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _rippleController?.reset();
      _rippleController?.forward();
    }
  }
  
  @override
  void dispose() {
    _rippleController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: 50,
          transform: Matrix4.translationValues(0, widget.isSelected ? 2 : -1, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isSelected
                  ? [Color.fromARGB(255, 73, 209, 102), Color.fromARGB(255, 73, 209, 102)]
                  : [Colors.white, Colors.grey[200]!],
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(2, 2),
                      blurRadius: 5,
                      spreadRadius: -1,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      offset: Offset(-2, -2),
                      blurRadius: 5,
                      spreadRadius: -1,
                    ),
                    BoxShadow(
                      color: Color(0xFF3B82F6).withOpacity(0.3),
                      offset: Offset(3, 3),
                      blurRadius: 8,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.7),
                      offset: Offset(-3, -3),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Ripple effect
              if (widget.isSelected && widget.tapPosition != null && _rippleAnimation != null && _rippleController != null)

              // Glow border
              if (widget.isSelected && _glowAnimation != null)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _glowAnimation!,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: GlowBorderPainter(
                          borderRadius: 12,
                          opacity: _glowAnimation!.value,
                        ),
                      );
                    },
                  ),
                ),
              
              // Particles effect
              if (widget.isSelected && _particlesAnimation != null && _rippleController != null)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particlesAnimation!,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ParticlesPainter(
                          animation: _particlesAnimation!,
                          controller: _rippleController!,
                        ),
                      );
                    },
                  ),
                ),
              
              // Label
              Center(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Color(0xFF2D3748),
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                    shadows: widget.isSelected
                        ? [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.2),
                            )
                          ]
                        : [],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Custom painter for glow border
class GlowBorderPainter extends CustomPainter {
  final double borderRadius;
  final double opacity;

  GlowBorderPainter({
    required this.borderRadius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(2),
      Radius.circular(borderRadius - 2),
    );
    
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3B82F6).withOpacity(opacity * 0.5),
          Color(0xFF2563EB).withOpacity(opacity * 0.5),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GlowBorderPainter oldDelegate) => 
      oldDelegate.opacity != opacity;
}

// Custom painter for particles effect
class ParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final AnimationController controller;

  ParticlesPainter({
    required this.animation,
    required this.controller,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value < 0.2) return;
    
    final centerX = size.width / 2;
    
    // Top particles
    _drawParticle(
      canvas, 
      Offset(centerX, 0), 
      animation.value, 
      Color(0xFF60A5FA),
      size,
      -1, // Moving up
    );
    
    _drawParticle(
      canvas, 
      Offset(centerX - 10, 0), 
      animation.value, 
      Color(0xFF60A5FA),
      size,
      -1,
    );
    
    _drawParticle(
      canvas, 
      Offset(centerX + 10, 0), 
      animation.value, 
      Color(0xFF60A5FA),
      size,
      -1,
    );
    
    // Bottom particles
    _drawParticle(
      canvas, 
      Offset(centerX, size.height), 
      animation.value, 
      Color(0xFF93C5FD),
      size,
      1, // Moving down
    );
    
    _drawParticle(
      canvas, 
      Offset(centerX - 10, size.height), 
      animation.value, 
      Color(0xFF93C5FD),
      size,
      1,
    );
    
    _drawParticle(
      canvas, 
      Offset(centerX + 10, size.height), 
      animation.value, 
      Color(0xFF93C5FD),
      size,
      1,
    );
  }
  
  void _drawParticle(Canvas canvas, Offset position, double animValue, Color color, Size size, int direction) {
    final progress = math.min(1.0, math.max(0.0, (animValue - 0.2) / 0.8));
    final opacity = 1.0 - progress;
    final yOffset = direction * 20 * progress;
    
    final Paint paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
      
    canvas.drawCircle(
      Offset(position.dx, position.dy + yOffset),
      6 * (1 - progress),
      paint,
    );
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}