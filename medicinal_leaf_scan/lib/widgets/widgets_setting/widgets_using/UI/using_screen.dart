import 'package:flutter/material.dart';

class UsingScreen extends StatelessWidget {
  const UsingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hướng dẫn sử dụng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0)
      ),
    );
  }
}
