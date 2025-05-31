import 'package:flutter/material.dart';
import 'UI/usage_screen.dart';

class UsingWidget extends StatelessWidget {
  const UsingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // THAY ĐỔI: từ 380 thành double.infinity
      height: 60,  
      child: Column(
        children: [
          // Nội dung phần Row
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              // Điều hướng đến màn hình UsingScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsingScreen()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,  // Canh trái
              children: [
                // Logo ở bên trái
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Image.asset(
                    'assets/icon/book.png', 
                    width: 38, 
                    height: 38, 
                  ),
                ),
                SizedBox(width: 10), 
                // Text "Cách sử dụng"
                Expanded(  
                  child: Text(
                    'Cách sử dụng', 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis, // THÊM: tránh text overflow
                  ),
                ),
                // Mũi tên ở bên phải
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    Icons.arrow_forward_ios, 
                    size: 25, 
                    color: Colors.black, 
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}