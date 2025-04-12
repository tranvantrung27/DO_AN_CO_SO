import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/navigation/navigation_bottom/navigation_bottom.dart';
import 'package:medicinal_leaf_scan/pages/scan.dart';
import 'package:medicinal_leaf_scan/pages/setting.dart';
import 'package:medicinal_leaf_scan/pages/history.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;  // Mặc định chọn màn hình "Quét"

  final List<Widget> _screens = [
    HistoryScreen(),
    ScanScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Các màn hình được hiển thị trong Stack
          _screens[_selectedIndex],  // Hiển thị màn hình tương ứng với mục đã chọn
          
          // Đảm bảo NavigationBottom luôn nằm ở dưới cùng và không bị che khuất
          Positioned(
            bottom: 0, // Đảm bảo nút NavigationBottom ở dưới cùng
            left: 0,
            right: 0,
            child: NavigationBottom(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
