import 'package:flutter/material.dart';
import 'UI/terms_conditions_screen.dart';

class TermsConditionsWidget extends StatelessWidget {
  const TermsConditionsWidget({super.key});

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
                MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Image.asset(
                    'assets/icon/terms-and-conditions.png',
                    width: 38,
                    height: 38,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded( // THÊM: Expanded để text responsive
                  child: Text(
                    'Điều khoản & Điều kiện',
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
