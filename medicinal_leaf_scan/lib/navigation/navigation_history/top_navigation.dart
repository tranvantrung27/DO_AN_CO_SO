import 'package:flutter/material.dart';
import 'history_navigation.dart';
import 'leaf_collection_navigation.dart';

class TopNavigation extends StatefulWidget {
  @override
  _TopNavigationState createState() => _TopNavigationState();
}

class _TopNavigationState extends State<TopNavigation> with SingleTickerProviderStateMixin {
  bool isHistorySelected = true;
  late AnimationController _animationController;
  late double historyTabWidth;
  late double leafCollectionTabWidth;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    historyTabWidth = 105;  // Chiều rộng của tab "Lịch sử"
    leafCollectionTabWidth = 140;  // Chiều rộng của tab "Bộ sưu tầm lá thuốc"
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      height: 50,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 178, 255, 191), 
        borderRadius: BorderRadius.circular(15), 
      ),
      child: Stack(
        children: [
          // Thanh  di chuyển
          AnimatedPositioned(
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            left: isHistorySelected ? 20 : 145, // Vị trí của thanh chỉ báo
            child: Container(
              width: isHistorySelected ? historyTabWidth : leafCollectionTabWidth, // Chiều rộng thay đổi tùy vào tab
              height: 40,
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFF8BC34A),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          
          // Các tab
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tab Lịch sử
              GestureDetector(
                onTap: () {
                  if (!isHistorySelected) {
                    setState(() {
                      isHistorySelected = true;
                    });
                  }
                },
                child: Container(
                  width: historyTabWidth, // Chiều rộng của tab "Lịch sử"
                  height: 40,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Center(child: HistoryNavigation()),
                ),
              ),
              SizedBox(width: 20),
              // Tab Bộ sưu tầm lá thuốc
              GestureDetector(
                onTap: () {
                  if (isHistorySelected) {
                    setState(() {
                      isHistorySelected = false;
                    });
                  }
                },
                child: Container(
                  width: leafCollectionTabWidth, // Chiều rộng của tab "Bộ sưu tầm lá thuốc"
                  height: 40,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: Center(child: LeafCollectionNavigation()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}