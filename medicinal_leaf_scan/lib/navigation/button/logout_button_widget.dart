import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';  // Import AppColors để sử dụng màu sắc

class LogoutButtonWidget extends StatelessWidget {
  // Hàm đăng xuất
// Hàm đăng xuất
Future<void> _logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();  // Đăng xuất người dùng
    
    // Sau khi đăng xuất, không thay đổi màn hình hiện tại
    // Chỉ cần quay lại màn hình SettingScreen
    Navigator.pushNamedAndRemoveUntil(context, '/setting', (route) => false); 
  } catch (e) {
    // Nếu có lỗi khi đăng xuất, hiển thị thông báo lỗi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi khi đăng xuất: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _logout(context),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), backgroundColor: AppColors.greenColor,  // Màu nền xanh lá cây
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),  // Bo tròn các góc
        ),
        elevation: 10,  // Thêm độ bóng cho nút
        shadowColor: Colors.greenAccent,  // Màu chữ trên nút
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,  // Đậm hơn và thanh thoát
        ),
      ),
      child: const Text(
        'Đăng xuất',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,  // Màu chữ trắng
        ),
      ),
    );
  }
}
