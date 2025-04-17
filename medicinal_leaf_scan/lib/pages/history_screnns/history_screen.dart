import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart'; // Import AppColors

class HistoryScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.bodyColor, // Áp dụng màu nền body từ AppColors
        child: Center(
          // Dùng Center để căn giữa tất cả phần tử
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Căn giữa theo chiều dọc
            crossAxisAlignment:
                CrossAxisAlignment.center, // Căn giữa theo chiều ngang
            children: [
              // Hiển thị logo history cho màn hình History
              Image.asset(
                'assets/logo_history/history.png',
                width: 300,
                height: 300,
              ),
              SizedBox(height: 20),
              // Hiển thị thông báo chưa có lịch sử
              Text(
                'Lịch sử chưa được ghi nhận\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Hãy bắt đầu khám phá\n để theo dõi các hoạt động của bạn',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
