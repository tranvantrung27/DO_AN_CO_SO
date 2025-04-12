import 'package:flutter/material.dart';

class TopNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,  // Chiều rộng 290
      height: 50,  // Chiều cao 50
      decoration: BoxDecoration(
        color: Color(0xFFE6FFD6),  // Màu nền #E6FFD6
        borderRadius: BorderRadius.circular(10),  // Bo góc 10
      ),
    );
  }
}
