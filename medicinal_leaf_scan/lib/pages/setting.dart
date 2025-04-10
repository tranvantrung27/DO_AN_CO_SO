// lib/screens/setting.dart
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: const Center(
        child: Text('This is the Settings screen'),
      ),
    );
  }
}
