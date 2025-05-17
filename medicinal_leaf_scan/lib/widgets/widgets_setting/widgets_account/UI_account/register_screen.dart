import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicinal_leaf_scan/main.dart'; // Import MainScreen
import 'package:medicinal_leaf_scan/navigation/button/register_button_widget.dart';
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
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    try {
      // Tạo tài khoản mới
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Gửi email xác thực
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng ký thành công! Đang chuyển hướng...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Chuyển trực tiếp đến MainScreen thay vì sang LoginScreen
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(initialIndex: 2),
          ),
          (route) => false,
        );
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
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
      } else if (e.code == 'weak-password') {
        setState(() {
          _passwordError = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        });
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi không xác định: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                const SizedBox(height: 30),

                // Nút đăng ký với loading indicator
                _isLoading 
                ? Center(child: CircularProgressIndicator(color: Colors.green))
                : RegisterButtonWidget(onPressed: _register),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Điều hướng đến màn hình đăng nhập
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