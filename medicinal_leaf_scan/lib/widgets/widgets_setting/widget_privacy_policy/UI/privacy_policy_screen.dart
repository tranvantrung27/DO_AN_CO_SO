import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Hàm lấy dữ liệu 'privacy_policy' từ Firestore collection 'app_info'
  Future<Map<String, dynamic>?> fetchPrivacyPolicy() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_info')
          .doc('privacy_policy')
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu privacy_policy: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bodyColor, // nền body theo theme
      body: CustomScrollView(
        slivers: [
          // SliverAppBar tương tự UsingScreen để đồng bộ UI
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
                'Chính sách bảo mật',
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
                    Icons.privacy_tip_rounded,
                    size: 50,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),

          // Nội dung chính với FutureBuilder xử lý dữ liệu từ Firestore
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: fetchPrivacyPolicy(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
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

  // Widget trạng thái loading spinner
  Widget _buildLoadingState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  // Widget trạng thái lỗi khi không tải được dữ liệu
  Widget _buildErrorState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy dữ liệu chính sách bảo mật',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thử lại sau',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị nội dung chính được format rõ ràng, đẹp mắt
  Widget _buildContent(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Chính sách bảo mật';
    final sections = data['sections'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card tiêu đề chính với nền gradient và shadow nhẹ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
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

          // Danh sách các section chi tiết của chính sách bảo mật
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

  // Widget card hiển thị từng phần nhỏ với số thứ tự rõ ràng
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  heading,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
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
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
