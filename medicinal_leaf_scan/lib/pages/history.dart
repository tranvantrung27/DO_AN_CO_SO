import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:medicinal_leaf_scan/navigation/navigation_history/top_navigation.dart';
import 'package:medicinal_leaf_scan/pages/history_screnns/collection_screen.dart';
import 'package:medicinal_leaf_scan/pages/history_screnns/history_screen.dart';  // Import màn hình HistoryScreen

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenPageState createState() => _HistoryScreenPageState();
}

class _HistoryScreenPageState extends State<HistoryScreen> {
  int _currentIndex = 0;

  void updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch sử',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.bodyColor,
        child: Column(
          children: [
            // TopNavigation với callback để nhận index được chọn
            TopNavigation(
              initialIndex: _currentIndex,
              onIndexChanged: updateIndex,
            ),
            
            // Hiển thị nội dung tương ứng với tab được chọn
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  // Tab 0: Lịch sử - Gọi màn hình HistoryScreen
                  HistoryScreenPage(),  // Thay thế Center bằng màn hình HistoryScreen

                  // Tab 1: Bộ sưu tập lá thuốc
                  CollectionScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
