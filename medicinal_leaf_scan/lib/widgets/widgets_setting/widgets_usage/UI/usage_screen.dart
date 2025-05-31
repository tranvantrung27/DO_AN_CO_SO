import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

class UsingScreen extends StatelessWidget {
  const UsingScreen({super.key});

  // Hàm lấy dữ liệu 'usage_guide' từ Firestore
  Future<Map<String, dynamic>?> fetchUsageGuide() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_info')
          .doc('usage_guide')
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu usage_guide: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor, // Màu nền Body ứng dụng
      body: CustomScrollView(
        slivers: [
          // SliverAppBar với hiệu ứng flexible, mở rộng khi kéo xuống
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true, // Giữ AppBar cố định khi scroll lên
            backgroundColor: AppColors.appBarColor,
            elevation: 0, // Tắt bóng đổ cho nền liền mạch
            shadowColor: Colors.transparent, // Tắt bóng màu
            surfaceTintColor: Colors.transparent, // Tắt hiệu ứng overlay (Material 3)
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Hướng dẫn sử dụng',
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
                    Icons.menu_book_rounded,
                    size: 50,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),

          // Nội dung chính dưới dạng SliverToBoxAdapter để scroll liền mạch
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: fetchUsageGuide(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(); // Widget loading khi chờ dữ liệu
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return _buildErrorState(); // Widget hiển thị lỗi khi không có dữ liệu
                }

                final data = snapshot.data!;
                return _buildContent(data); // Widget hiển thị nội dung chính
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget loading dạng trung tâm, kèm text mô tả
  Widget _buildLoadingState() {
    return Container(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải hướng dẫn...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget lỗi khi không tìm thấy dữ liệu
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
              'Không tìm thấy dữ liệu hướng dẫn',
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

  // Widget chính hiển thị nội dung dữ liệu
  Widget _buildContent(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Hướng dẫn sử dụng';
    final description = data['description'] ?? '';
    final sections = data['sections'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header chứa tiêu đề và mô tả
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hiển thị danh sách các section dạng Card
          ...sections.asMap().entries.map((entry) {
            final index = entry.key;
            final section = entry.value;
            final heading = section['heading'] ?? '';
            final content = section['content'] ?? '';

            return _buildSectionCard(
              index: index + 1,
              heading: heading,
              content: content,
            );
          }).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget hiển thị từng section dạng card với số thứ tự
  Widget _buildSectionCard({
    required int index,
    required String heading,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  heading,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
