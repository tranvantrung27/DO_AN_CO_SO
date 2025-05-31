import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart'; 
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/UI_account/register_screen.dart'; 

class AccountSettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () {
        if (user == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        }
      },
      child: Container(
        width: double.infinity, // THAY ĐỔI: từ 380 thành double.infinity
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
            // Khoảng cách giữa logo và chữ
            SizedBox(width: 10), 
            // Text responsive
            Expanded(  
              child: Text(
                user == null ? 'Tài khoản' : user.email!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis, // THÊM: tránh text overflow
              ),
            ),
            // Mũi tên
            if (user == null) 
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
    );
  }
}