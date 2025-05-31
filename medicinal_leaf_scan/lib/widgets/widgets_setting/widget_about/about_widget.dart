import 'package:flutter/material.dart';
import 'UI/about_screen.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // THAY ĐỔI: từ 380 thành double.infinity
      height: 60,  
      child: Column(
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Image.asset(
                    'assets/icon/Info.png', 
                    width: 38, 
                    height: 38, 
                  ),
                ),
                const SizedBox(width: 10), 
                Expanded(  
                  child: Text(
                    'Thông tin giới thiệu', 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis, // THÊM: tránh text overflow
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
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