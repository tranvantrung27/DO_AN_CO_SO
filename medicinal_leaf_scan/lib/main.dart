import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medicinal_leaf_scan/firebase_options.dart';
import 'package:medicinal_leaf_scan/navigation/navigation_bottom/navigation_bottom.dart';
import 'package:medicinal_leaf_scan/pages/nhandien/ketqua/detail_screen.dart';
import 'package:medicinal_leaf_scan/pages/scan.dart' as ScanPage;
import 'package:medicinal_leaf_scan/pages/setting.dart';
import 'package:medicinal_leaf_scan/pages/history.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/UI_account/login_screen.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/UI_account/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainScreen(),
      routes: {
        '/detail': (context) => const DetailScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/setting': (context) => SettingScreen(),
        
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({super.key, this.initialIndex = 1});  // Mặc định là tab Quét (index 1)

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;  // Sẽ được khởi tạo dựa trên initialIndex
  
  // THÊM: GlobalKey để truy cập ScanScreen
  final GlobalKey _scanScreenKey = GlobalKey();

  // SỬA: Thêm key cho ScanScreen
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;  // Lấy index từ constructor
    
    // THÊM: Khởi tạo danh sách screens với key cho ScanScreen
    _screens = [
      HistoryScreen(),                               // index 0
      ScanPage.ScanScreen(key: _scanScreenKey),     // index 1 - THÊM KEY
      SettingScreen(),                              // index 2
    ];
  }

  // SỬA: Logic xử lý khi tap vào navigation
  void _onItemTapped(int index) {
    if (index == 1 && _selectedIndex == 1) {
      // THÊM: Nếu đang ở màn hình scan và nhấn lại nút scan -> chụp ảnh
      final scanScreen = _scanScreenKey.currentState;
      if (scanScreen != null) {
        // Gọi method chụp ảnh nếu có
        (scanScreen as dynamic).capturePhoto?.call();
      }
    } else {
      // Chuyển đổi màn hình bình thường
      setState(() {
        _selectedIndex = index;
      });
    }
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