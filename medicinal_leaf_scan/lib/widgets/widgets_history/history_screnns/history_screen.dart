import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart'; 

class HistoryScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.bodyColor, 
        child: Center(
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
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Lịch sử chưa được ghi nhận\n\n',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold, 
                        color: const Color.fromARGB(255, 2, 105, 5),
                      ),
                    ),
                    TextSpan(
                      text:
                          'Hãy bắt đầu khám phá\n để theo dõi các hoạt động của bạn.',
                      style: TextStyle(
                        fontSize: 20,
                        color: const Color.fromARGB(255, 2, 105, 5),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
