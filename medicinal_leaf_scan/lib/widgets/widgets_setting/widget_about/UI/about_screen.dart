import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Hàm lấy dữ liệu 'about' từ Firestore trong collection 'app_info'
  Future<Map<String, dynamic>?> fetchAboutData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_info')
          .doc('about')
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu about: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor, // Nền body theo theme
      body: CustomScrollView(
        slivers: [
          // SliverAppBar có hiệu ứng mở rộng và cố định khi cuộn
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.appBarColor,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Thông tin giới thiệu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.appBarColor,
                      AppColors.appBarColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 50,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),

          // Nội dung chính nằm trong SliverToBoxAdapter để cuộn mượt
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: fetchAboutData(),
              builder: (context, snapshot) {
                // Trạng thái đang tải dữ liệu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                // Trường hợp lỗi hoặc không có dữ liệu
                if (!snapshot.hasData || snapshot.data == null) {
                  return _buildErrorState();
                }

                final data = snapshot.data!;
                return _buildContent(data);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget loading spinner
  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Widget hiển thị lỗi khi không lấy được dữ liệu
  Widget _buildErrorState() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy dữ liệu giới thiệu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng thử lại sau',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị nội dung chính
  Widget _buildContent(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Thông tin giới thiệu';
    final content = data['content'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card tiêu đề
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade50,
                  Colors.blue.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nội dung mô tả chi tiết
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
