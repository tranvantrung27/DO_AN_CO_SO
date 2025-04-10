import 'package:flutter/material.dart';
import 'navigation_icons.dart'; // Import NavigationIcons

class NavigationBottom extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavigationBottom({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<NavigationBottom> createState() => _NavigationBottomState();
}

class _NavigationBottomState extends State<NavigationBottom> {
  // Biến lưu vị trí Y của icon scan
  double scanYPosition = 0;

  @override
  void initState() {
    super.initState();
    // Kiểm tra vị trí ban đầu
    if (widget.selectedIndex == 1) {
      scanYPosition = -20; // Nếu scan được chọn, nổi lên
    }
  }

  @override
  void didUpdateWidget(NavigationBottom oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cập nhật vị trí khi thay đổi tab
    setState(() {
      if (widget.selectedIndex == 1) {
        scanYPosition = -20; // Khi chọn scan, nổi lên
      } else {
        scanYPosition = 20; // Khi chọn tab khác, trở về vị trí gốc
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Ensure enough height for the navigation bar
      width: 430,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none, // Prevent clipping of the Scan button
        children: [
          // Gọi widget NavigationIcons từ file navigation_icons.dart
          NavigationIcons(
            selectedIndex: widget.selectedIndex,
            onItemTapped: widget.onItemTapped,
          ),

          // Scan Button ở giữa với animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: scanYPosition - 10,
            child: GestureDetector(
              onTap: () => widget.onItemTapped(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.selectedIndex == 1 ? Colors.blue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Stronger shadow
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo_navigation/scan_icon.png',
                    width: 30,
                    height: 30,
                    color: widget.selectedIndex == 1 ? Colors.white : Colors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}