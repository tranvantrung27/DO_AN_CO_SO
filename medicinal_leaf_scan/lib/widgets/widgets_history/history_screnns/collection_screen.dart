import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

class CollectionScreen extends StatelessWidget {
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
              // Hiển thị logo 
              Image.asset(
                'assets/logo_history/save.png',
                width: 300,
                height: 300,
              ),
              SizedBox(height: 20),
           
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bộ sưu tập lá thuốc trống rỗng\n\n',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold, 
                        color: const Color.fromARGB(255, 2, 105, 5),
                      ),
                    ),
                    TextSpan(
                      text:
                          'Hãy ghi lại những lá thuốc quý giá\n và hữu ích cho bạn!',
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
