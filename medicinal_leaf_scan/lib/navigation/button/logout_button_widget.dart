import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicinal_leaf_scan/main.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

class LogoutButtonWidget extends StatefulWidget {
  @override
  _LogoutButtonWidgetState createState() => _LogoutButtonWidgetState();
}

class _LogoutButtonWidgetState extends State<LogoutButtonWidget> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Kiểm tra trạng thái đăng nhập khi widget được khởi tạo
    _checkLoginStatus();
    
    // Lắng nghe các thay đổi về trạng thái đăng nhập
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
        });
      }
    });
  }
  
  // Kiểm tra trạng thái đăng nhập hiện tại
  void _checkLoginStatus() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        _isLoggedIn = currentUser != null;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Hàm đăng xuất
  Future<void> _logout(BuildContext context) async {
    if (_isLoading || !_isLoggedIn) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Bắt đầu animation fade out
      _animationController.forward();

      // Đợi một chút để animation bắt đầu
      await Future.delayed(const Duration(milliseconds: 100));

      // Đăng xuất người dùng
      await FirebaseAuth.instance.signOut();

      // Thêm một chút delay để hiệu ứng mượt mà hơn
      await Future.delayed(const Duration(milliseconds: 200));

      // Chuyển đến màn hình chính với hiệu ứng fade
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            MainScreen(initialIndex: 2),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            var curve = Curves.easeInOut;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve)
            );
            
            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    } catch (e) {
      // Reset trạng thái loading nếu có lỗi
      setState(() {
        _isLoading = false;
        _animationController.reverse();
      });
      
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đăng xuất: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu người dùng chưa đăng nhập, return một SizedBox rỗng (không hiển thị nút)
    if (!_isLoggedIn) {
      return SizedBox();
    }
    
    // Nếu người dùng đã đăng nhập, hiển thị nút đăng xuất
    return FadeTransition(
      opacity: _animation,
      child: ElevatedButton(
        onPressed: () => _logout(context),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: 15, 
            horizontal: _isLoading ? 40 : 30,
          ),
          backgroundColor: AppColors.greenColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 10,
          shadowColor: Colors.greenAccent,
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: _isLoading 
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
          : const Text(
              'Đăng xuất',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      ),
    );
  }
}