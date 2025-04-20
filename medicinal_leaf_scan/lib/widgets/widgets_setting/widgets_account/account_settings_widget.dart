import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';  // Giả sử bạn sử dụng AppColors

class AccountSettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,  
      height: 60, 
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor, 
        borderRadius: BorderRadius.circular(10),  
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(2, 2),
            blurRadius: 5,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          // Logo ở bên trái
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Image.asset(
              'assets/icon/account.png', 
              width: 38, 
              height: 38, 
            ),
          ),
          // Khoảng cách giữa logo và chữ "Tài khoản"
          SizedBox(width: 10), 
          // Text "Tài khoản"
          Expanded(  
            child: Text(
              'Tài khoản', 
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
    );
  }
}
