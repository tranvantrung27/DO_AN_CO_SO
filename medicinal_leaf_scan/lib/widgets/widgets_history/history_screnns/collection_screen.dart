import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../pages/nhandien/ketqua/services/leaf_data_service.dart';

class CollectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Nếu người dùng chưa đăng nhập, hiển thị bộ sưu tập trống
    if (user == null) {
      return _buildEmptyCollectionView();
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('collections') // Collection bộ sưu tập
              .where('userId', isEqualTo: user.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.greenColor),
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
          return _buildEmptyCollectionView();
        }

        return _buildCollectionList(snapshot.data!.docs);
      },
    );
  }

  Widget _buildEmptyCollectionView() {
    return Container(
      color: AppColors.bodyColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_history/save.png',
              width: 300,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.bookmark_border,
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
                    text: 'Bộ sưu tập lá thuốc trống rỗng\n\n',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 2, 105, 5),
                    ),
                  ),
                  TextSpan(
                    text:
                        'Hãy ghi lại những lá thuốc quý giá\n và hữu ích cho bạn!',
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

  Widget _buildCollectionList(List<QueryDocumentSnapshot> docs) {
    return Container(
      color: AppColors.bodyColor,
      child: SafeArea(
        bottom: true,
        child: ListView.builder(
          // Thêm padding bottom để có khoảng cách với navigation bar
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + 60),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return CollectionItem(data: data, documentId: docs[index].id);
          },
        ),
      ),
    );
  }
}

class CollectionItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final String documentId;

  const CollectionItem({Key? key, required this.data, required this.documentId})
    : super(key: key);

  @override
  _CollectionItemState createState() => _CollectionItemState();
}

class _CollectionItemState extends State<CollectionItem> {
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
        // Sử dụng LeafDataCache thay vì LeafDataService trực tiếp
        final leafData = await LeafDataCache().getLeafData(leafId);
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
      confidence =
          widget.data['confidence'] is double
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
        // Trong _HistoryItemState và _CollectionItemState,
        // điều chỉnh hàm onTap trong InkWell:
        // Trong _HistoryItemState và _CollectionItemState
        onTap: () async {
          // Kiểm tra nếu dữ liệu chưa tải xong thì đợi
          if (_isLoading) {
            // Hiển thị tiến trình loading nếu cần
            await _loadLeafData();
          }

          // Sau đó mới điều hướng với dữ liệu đã tải
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
              // Ảnh lá
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),
                    // Thời gian lưu
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
                        // Icon đánh dấu yêu thích
                        Icon(Icons.favorite, color: Colors.red, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey[400]),
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
        child: Icon(Icons.eco, size: 40, color: AppColors.greenColor),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.greenColor,
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(Icons.eco, size: 40, color: Colors.grey),
          ),
    );
  }
}
