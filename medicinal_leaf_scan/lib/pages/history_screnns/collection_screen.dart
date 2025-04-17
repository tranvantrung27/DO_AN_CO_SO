import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart'; // Import AppColors

class CollectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.bodyColor, // Áp dụng màu nền body từ AppColors
        child: Center( // Dùng Center để căn giữa tất cả phần tử
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Căn giữa theo chiều dọc
            crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều ngang
            children: [
              // Hiển thị logo save cho màn hình Collection
              Image.asset(
                'assets/logo_history/save.png', 
                width: 300, 
                height: 300,
              ),
              SizedBox(height: 20),
              // Hiển thị thông báo bộ sưu tập trống
              Text(
                'Bộ sưu tập lá thuốc trống rỗng\n',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Hãy ghi lại những lá thuốc quý giá\n và hữu ích cho bạn!',
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
