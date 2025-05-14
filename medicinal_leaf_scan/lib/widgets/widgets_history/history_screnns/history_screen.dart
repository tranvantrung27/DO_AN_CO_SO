import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../pages/nhandien/ketqua/services/leaf_data_service.dart';

class HistoryScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildNotLoggedInView();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('history')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.greenColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Có lỗi xảy ra: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyHistoryView();
        }

        return _buildHistoryList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildNotLoggedInView() {
    return Container(
      color: AppColors.bodyColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: AppColors.greenColor,
            ),
            SizedBox(height: 20),
            Text(
              'Vui lòng đăng nhập để xem lịch sử',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.greenColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistoryView() {
    return Container(
      color: AppColors.bodyColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_history/history.png',
              width: 300,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.history,
                  size: 150,
                  color: AppColors.greenColor.withOpacity(0.5),
                );
              },
            ),
            SizedBox(height: 20),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Lịch sử chưa được ghi nhận\n\n',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 2, 105, 5),
                    ),
                  ),
                  TextSpan(
                    text: 'Hãy bắt đầu khám phá\n để theo dõi các hoạt động của bạn.',
                    style: TextStyle(
                      fontSize: 20,
                      color: const Color.fromARGB(255, 2, 105, 5),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<QueryDocumentSnapshot> docs) {
    return Container(
      color: AppColors.bodyColor,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
          return _HistoryItem(
            data: data,
            documentId: docs[index].id,
          );
        },
      ),
    );
  }
}

class _HistoryItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final String documentId;

  const _HistoryItem({
    Key? key,
    required this.data,
    required this.documentId,
  }) : super(key: key);

  @override
  _HistoryItemState createState() => _HistoryItemState();
}

class _HistoryItemState extends State<_HistoryItem> {
  Map<String, dynamic>? _leafData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeafData();
  }

  Future<void> _loadLeafData() async {
    try {
      final leafId = widget.data['leafId'];
      if (leafId != null) {
        final leafData = await LeafDataService.loadLeafData(leafId);
        if (mounted) {
          setState(() {
            _leafData = leafData;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading leaf data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.data['timestamp'] as Timestamp?;
    String dateString = 'Không rõ';
    if (timestamp != null) {
      try {
        dateString = DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());
      } catch (e) {
        dateString = 'Không rõ';
      }
    }

    String description = '';
    if (!_isLoading && _leafData != null) {
      description = _leafData!['description'] ?? '';
    }

    // Giới hạn mô tả
    if (description.length > 100) {
      description = '${description.substring(0, 100)}...';
    }

    // Lấy giá trị confidence an toàn
    double confidence = 0.0;
    if (widget.data['confidence'] != null) {
      confidence = widget.data['confidence'] is double 
          ? widget.data['confidence'] 
          : (widget.data['confidence'] as num).toDouble();
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.greenColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: {
              'imageUrl': widget.data['imageUrl'],
              'leafId': widget.data['leafId'],
              'leafName': widget.data['leafName'] ?? 'Chưa xác định',
              'confidence': confidence,
              'leafData': _leafData,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Ảnh lá - Xử lý trường hợp không có imageUrl
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(),
              ),
              SizedBox(width: 16),
              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên lá
                    Text(
                      widget.data['leafName'] ?? 'Chưa xác định',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    // Mô tả
                    if (description.isNotEmpty)
                      Text(
                        'Mô tả: $description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),
                    // Ngày quét và độ chính xác
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            dateString,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.greenColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    final imageUrl = widget.data['imageUrl'];
    
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: Icon(
          Icons.eco,
          size: 40,
          color: AppColors.greenColor,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.greenColor,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.eco,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}