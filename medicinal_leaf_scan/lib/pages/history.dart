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
  String _appBarTitle = 'Lịch sử'; // Tiêu đề mặc định

  void updateIndex(int index) {
    setState(() {
      _currentIndex = index;
      // Cập nhật tiêu đề khi người dùng chọn tab
      if (_currentIndex == 0) {
        _appBarTitle = 'Lịch sử'; // Tiêu đề khi ở tab Lịch sử
      } else {
        _appBarTitle = 'Bộ sưu tập lá thuốc'; // Tiêu đề khi ở tab Bộ sưu tập lá thuốc
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle, // Hiển thị tiêu đề động
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.bodyColor,
        child: Column(
          children: [
            // TopNavigation cho phép chuyển đổi tab
            TopNavigation(
              initialIndex: _currentIndex,
              onIndexChanged: updateIndex, // Cập nhật tiêu đề khi chuyển tab
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  // Tab 0: Lịch sử - Gọi màn hình HistoryScreen
                  Center(  // Đảm bảo màn hình con được căn giữa
                    child: HistoryScreenPage(),
                  ),
                  // Tab 1: Bộ sưu tập lá thuốc
                  Center(  // Đảm bảo màn hình con được căn giữa
                    child: CollectionScreen(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
