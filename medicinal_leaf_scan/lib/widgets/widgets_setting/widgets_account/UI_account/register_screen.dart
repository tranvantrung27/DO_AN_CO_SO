import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicinal_leaf_scan/navigation/button/register_button_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/UI_account/login_screen.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/UI_account/widgets/input_field_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isPasswordVisible = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Mật khẩu không khớp!';
      });
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng ký thành công!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Điều hướng qua trang đăng nhập
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ), // Điều hướng sang trang đăng nhập
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        setState(() {
          _emailError = 'Địa chỉ email không hợp lệ';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _emailError = 'Email đã tồn tại. Vui lòng đăng nhập bằng email này.';
        });
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email đã tồn tại. Vui lòng đăng nhập.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Hiển thị các lỗi khác
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Text
                Text(
                  'Tạo tài khoản mới',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field using InputFieldWidget
                InputFieldWidget(
                  controller: _emailController,
                  label: 'Email',
                  errorText: _emailError,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email không được bỏ trống';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.email, color: Colors.green),
                ),
                const SizedBox(height: 20),

                // Password Field using InputFieldWidget
                InputFieldWidget(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  errorText: _passwordError,
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mật khẩu không được bỏ trống';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Field using InputFieldWidget
                InputFieldWidget(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu',
                  errorText: _confirmPasswordError,
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Xác nhận mật khẩu không được bỏ trống';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  prefixIcon: Icon(Icons.lock, color: Colors.green),
                ),
                const SizedBox(height: 30),

                RegisterButtonWidget(onPressed: _register),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Điều hướng đến màn hình đăng ký
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    'Đã có tài khoản? Đăng Nhập tại đây',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
