import 'package:flutter/material.dart';

class InputFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showSuffixIcon;

  const InputFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.obscureText = false,
    this.validator,
    required this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.showSuffixIcon = true, // Thêm tham số để quyết định hiển thị icon
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: prefixIcon,  // Thêm icon vào bên trái
        suffixIcon: showSuffixIcon ? suffixIcon : null,  // Điều kiện để hiển thị icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}
