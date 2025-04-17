import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/navigation/navigation_history/top_navigation.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

class HistoryScreen extends StatelessWidget {
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
        child: Stack(
          children: [
            Positioned(
              top: 5, // Đặt vị trí Y tại 125
              left: (MediaQuery.of(context).size.width - 290) / 2,
              child: TopNavigation(),
            ),
          ],
        ),
      ),
    );
  }
}
