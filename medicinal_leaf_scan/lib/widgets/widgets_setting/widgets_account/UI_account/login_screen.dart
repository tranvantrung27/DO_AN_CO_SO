import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicinal_leaf_scan/main.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/UI_account/widgets/input_field_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Đăng nhập
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if still mounted before proceeding
      if (!mounted) return;

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thành công!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // Thời gian ngắn để hiển thị thông báo
      await Future.delayed(const Duration(milliseconds: 500));

      // Kiểm tra lại mounted
      if (!mounted) return;

      // Đơn giản hóa hoàn toàn việc chuyển màn hình, không dùng PageRouteBuilder
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 2)),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      // Phần xử lý lỗi giữ nguyên như cũ
      if (e.code == 'user-not-found') {
        errorMessage =
            'Email chưa được đăng ký. Vui lòng kiểm tra lại hoặc đăng ký tài khoản mới.';
        setState(() {
          _emailError = errorMessage;
        });
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mật khẩu không đúng. Vui lòng thử lại.';
        setState(() {
          _passwordError = errorMessage;
        });
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email không đúng định dạng. Vui lòng kiểm tra lại.';
        setState(() {
          _emailError = errorMessage;
        });
      } else if (e.code == 'too-many-requests') {
        errorMessage =
            'Quá nhiều lần thử đăng nhập không thành công. Vui lòng thử lại sau.';
        setState(() {
          _emailError = errorMessage;
        });
      } else {
        errorMessage = 'Đăng nhập không thành công. Vui lòng thử lại sau.';
        setState(() {
          _emailError = errorMessage;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi không xác định: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Hiển thị thông báo đăng nhập thành công ở vị trí giữa màn hình

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
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
                  'Đăng nhập tài khoản của bạn',
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
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.green.withOpacity(0.6),
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                          : const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Chưa có tài khoản? Đăng ký tại đây',
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
