import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Để lấy thông tin người dùng
import 'package:medicinal_leaf_scan/utils/app_colors.dart'; 
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/UI_account/register_screen.dart'; 

class AccountSettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem người dùng đã đăng nhập hay chưa
    User? user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () {
        if (user == null) {
          // Nếu chưa đăng nhập, chuyển tới màn hình đăng ký
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterScreen()),
          );
        }
      },
      child: Container(
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
            // Text "Tài khoản" hoặc email người dùng nếu đã đăng nhập
            Expanded(  
              child: Text(
                user == null ? 'Tài khoản' : user.email!, // Hiển thị email nếu đăng nhập
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Ẩn mũi tên khi người dùng đã đăng nhập
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
