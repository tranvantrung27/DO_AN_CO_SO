import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/leaf_info_widget.dart';
import 'services/leaf_data_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoadingLeafData = true;
  Map<String, dynamic>? _leafData;

  // Biến để kiểm soát trạng thái lưu
  bool _isSavingToCollection = false;
  bool _isSavedToCollection = false;
  String? _collectionDocId;

  bool _isSavingToHistory = false;
  bool _isSavedToHistory = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final leafId = args['leafId'] as String;

    // Nếu đã có leafData từ history/collection, sử dụng nó
    if (args.containsKey('leafData') && args['leafData'] != null) {
      setState(() {
        _leafData = args['leafData'] as Map<String, dynamic>;
        _isLoadingLeafData = false;
      });
    } else {
      // Ngược lại, load từ service
      final leafData = await LeafDataService.loadLeafData(leafId);
      if (mounted) {
        setState(() {
          _leafData = leafData;
          _isLoadingLeafData = false;
        });
      }
    }

    // Kiểm tra xem đã lưu trong collection và history chưa
    _checkIfInCollection(leafId);
    _checkIfInHistory(leafId);
  }

  // Kiểm tra đã lưu vào BST chưa
  Future<void> _checkIfInCollection(String leafId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('collections')
              .where('userId', isEqualTo: user.uid)
              .where('leafId', isEqualTo: leafId)
              .limit(1)
              .get();

      if (mounted && querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isSavedToCollection = true;
          _collectionDocId = querySnapshot.docs.first.id;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra bộ sưu tập: $e');
    }
  }

  // Kiểm tra đã lưu vào lịch sử chưa
  Future<void> _checkIfInHistory(String leafId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('history')
              .where('userId', isEqualTo: user.uid)
              .where('leafId', isEqualTo: leafId)
              .limit(1)
              .get();

      if (mounted && querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isSavedToHistory = true;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra lịch sử: $e');
    }
  }

  // Lưu vào BST
  Future<void> _saveToCollection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final leafId = args['leafId'] as String;
    final leafName = args['leafName'] as String;
    final confidence = args['confidence'] as double;
    final imageUrl = args['imageUrl'] as String?;

    setState(() => _isSavingToCollection = true);

    try {
      // Lưu vào Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('collections')
          .add({
            'userId': user.uid,
            'leafName': leafName,
            'leafId': leafId,
            'confidence': confidence,
            'timestamp': FieldValue.serverTimestamp(),
            'imageUrl': imageUrl ?? '',
          });

      if (mounted) {
        setState(() {
          _isSavedToCollection = true;
          _collectionDocId = docRef.id;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu vào bộ sưu tập'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving to collection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingToCollection = false);
      }
    }
  }

  // Xóa khỏi BST
  Future<void> _removeFromCollection() async {
    if (_collectionDocId == null) return;

    setState(() => _isSavingToCollection = true);

    try {
      await FirebaseFirestore.instance
          .collection('collections')
          .doc(_collectionDocId)
          .delete();

      if (mounted) {
        setState(() {
          _isSavedToCollection = false;
          _collectionDocId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi bộ sưu tập'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing from collection: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingToCollection = false);
      }
    }
  }

  // Lưu vào lịch sử
  Future<void> _saveToHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final leafId = args['leafId'] as String;
    final leafName = args['leafName'] as String;
    final confidence = args['confidence'] as double;
    final imageUrl = args['imageUrl'] as String?;

    setState(() => _isSavingToHistory = true);

    try {
      // Lưu vào Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('history')
          .add({
            'userId': user.uid,
            'leafName': leafName,
            'leafId': leafId,
            'confidence': confidence,
            'timestamp': FieldValue.serverTimestamp(),
            'imageUrl': imageUrl ?? '',
          });

      if (mounted) {
        setState(() {
          _isSavedToHistory = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu vào lịch sử'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving to history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingToHistory = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String? imageUrl = args['imageUrl'] as String?;
    final String leafName = args['leafName'] as String;
    final double confidence = args['confidence'] as double;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lá'),
        backgroundColor: AppColors.appBarColor,
        actions: [
          // Icon lưu vào BST
          _isSavingToCollection
              ? Container(
                margin: const EdgeInsets.all(10),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : IconButton(
                icon: Icon(
                  _isSavedToCollection ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                tooltip:
                    _isSavedToCollection
                        ? 'Xóa khỏi bộ sưu tập'
                        : 'Lưu vào bộ sưu tập',
                onPressed:
                    _isSavedToCollection
                        ? _removeFromCollection
                        : _saveToCollection,
              ),

          // Icon lưu vào lịch sử
          _isSavingToHistory
              ? Container(
                margin: const EdgeInsets.all(10),
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : IconButton(
                icon: Icon(
                  _isSavedToHistory ? Icons.history : Icons.history_outlined,
                  color: Colors.white,
                ),
                tooltip: 'Lưu vào lịch sử',
                onPressed:
                    _isSavedToHistory
                        ? null // Nếu đã lưu thì không làm gì
                        : _saveToHistory,
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hiển thị ảnh và tên lá
            _buildImagePreview(imageUrl, leafName),

            // Container thông tin
            _buildResultContainer(confidence),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String? imageUrl, String leafName) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(color: AppColors.greenColor.withOpacity(0.1)),
      child: Stack(
        children: [
          // Ảnh lá
          Center(
            child:
                imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                      placeholder:
                          (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: AppColors.greenColor,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Icon(
                            Icons.eco,
                            size: 80,
                            color: AppColors.greenColor.withOpacity(0.5),
                          ),
                    )
                    : Icon(Icons.eco, size: 80, color: AppColors.greenColor),
          ),

          // Gradient overlay ở dưới để làm nổi bật tên lá
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),

          // Tên lá
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leafName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_leafData != null && _leafData!['englishName'] != null)
                  Text(
                    _leafData!['englishName'],
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContainer(double confidence) {
    final confidenceText = (confidence * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề và độ chính xác
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .center, // Thêm dòng này để căn giữa tất cả items trong Row
            children: [
              const Text(
                'Thông tin về lá thuốc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // textAlign: TextAlign.center không cần thiết ở đây vì đã có mainAxisAlignment
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nội dung
          if (_isLoadingLeafData)
            const Center(child: CircularProgressIndicator())
          else if (_leafData == null)
            const Text(
              'Không tìm thấy thông tin chi tiết về loại lá này.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            )
          else
            LeafInfoWidget(leafData: _leafData!),
        ],
      ),
    );
  }
}
