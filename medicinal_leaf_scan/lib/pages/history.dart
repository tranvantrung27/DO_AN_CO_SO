import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:medicinal_leaf_scan/navigation/navigation_history/top_navigation.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_history/history_screnns/collection_screen.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_history/history_screnns/history_screen.dart'; 

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenPageState createState() => _HistoryScreenPageState();
}

class _HistoryScreenPageState extends State<HistoryScreen> {
  int _currentIndex = 0;
  String _appBarTitle = 'Lịch sử'; 

  void updateIndex(int index) {
    setState(() {
      _currentIndex = index;

      if (_currentIndex == 0) {
        _appBarTitle = 'Lịch sử'; 
      } else {
        _appBarTitle = 'Bộ sưu tập lá thuốc'; 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle, 
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
              onIndexChanged: updateIndex, 
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  // Tab 0: Lịch sử - Gọi màn hình HistoryScreen
                  Center( 
                    child: HistoryScreenPage(),
                  ),
                  // Tab 1: Bộ sưu tập lá thuốc
                  Center(  
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
