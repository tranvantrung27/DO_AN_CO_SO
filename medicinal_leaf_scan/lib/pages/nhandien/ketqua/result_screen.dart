import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/services/imgbb_service.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import các components
import 'services/action_buttons.dart';
import 'services/image_preview.dart';
import 'services/leaf_info_widget.dart';
import 'utils/labels_reader.dart';
import 'services/leaf_data_service.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> recognitionResult;

  const ResultScreen({
    Key? key,
    required this.imageFile,
    required this.recognitionResult,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isSavedToCollection = false;
  bool _isSavedToHistory = false;
  Map<String, dynamic>? _leafData;
  bool _isLoadingLeafData = true;
  String? _collectionDocId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
  try {
    await LabelsReader.loadLabelsMapping();
    final leafData = await LeafDataService.loadLeafData(
      widget.recognitionResult['class'] as String,
    );

    // Kiểm tra mounted trước khi cập nhật state
    if (!mounted) return;
    setState(() {
      _leafData = leafData;
      _isLoadingLeafData = false;
    });

    // Tự động lưu lịch sử nhưng với kiểm tra mounted
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      // Sử dụng Future.microtask để tránh việc chặn UI
      Future.microtask(() => _saveToHistory());
    }

    // Kiểm tra bộ sưu tập nếu vẫn mounted
    if (mounted) {
      await _checkIfInCollection();
    }
  } catch (e) {
    debugPrint('Lỗi trong _initializeData: $e');
    // Xử lý lỗi tốt hơn ở đây nếu cần
  }
}

  Future<void> _saveToHistory() async {
    // Nếu đã lưu rồi thì không lưu lại
    if (_isSavedToHistory) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Không hiển thị prompt nếu đang tự động lưu

    // Lưu trạng thái trước khi async
    if (mounted) {
      setState(() => _isSaving = true);
    }

    try {
      // Upload ảnh lên ImgBB
      final imageUrl = await ImgbbService.uploadImage(widget.imageFile);

      // Lưu thông tin vào Firestore cùng với URL ảnh
      await FirebaseFirestore.instance.collection('history').add({
        'userId': user.uid,
        'leafName':
            _leafData != null
                ? _leafData!['vietnameseName']
                : widget.recognitionResult['class'],
        'leafId': widget.recognitionResult['class'],
        'confidence': widget.recognitionResult['confidence'],
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
      });

      // Kiểm tra mounted trước khi cập nhật UI
      if (mounted) {
        setState(() => _isSavedToHistory = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu vào lịch sử'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving to history: $e');
      // Chỉ hiển thị lỗi nếu widget vẫn mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Kiểm tra mounted trước khi reset isSaving
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _checkIfInCollection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('collections')
              .where('userId', isEqualTo: user.uid)
              .where('leafId', isEqualTo: widget.recognitionResult['class'])
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isSavedToCollection = true;
          _collectionDocId = querySnapshot.docs.first.id;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra bộ sưu tập: $e');
    }
  }

  Future<void> _saveToCollection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginPrompt();
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Hiển thị thông báo đang upload
      // Upload ảnh lên ImgBB
      final imageUrl = await ImgbbService.uploadImage(widget.imageFile);

      if (imageUrl.isEmpty) {
        throw Exception('Không thể upload ảnh');
      }

      // Lưu dữ liệu vào Firestore với URL từ ImgBB
      final docRef = await FirebaseFirestore.instance
          .collection('collections')
          .add({
            'userId': user.uid,
            'leafName':
                _leafData != null
                    ? _leafData!['vietnameseName']
                    : widget.recognitionResult['class'],
            'leafId': widget.recognitionResult['class'],
            'confidence': widget.recognitionResult['confidence'],
            'timestamp': FieldValue.serverTimestamp(),
            'imageUrl': imageUrl, // URL từ ImgBB
          });

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
    } catch (e) {
      debugPrint('Error saving to collection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _removeFromCollection() async {
    if (_collectionDocId == null) return;

    setState(() => _isSaving = true);

    try {
      // Xóa document từ Firestore
      await FirebaseFirestore.instance
          .collection('collections')
          .doc(_collectionDocId)
          .delete();

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
    } catch (e) {
      debugPrint('Error removing from collection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xóa: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.recognitionResult['class'] == null) {
      return _buildErrorScreen();
    }

    final leafName = widget.recognitionResult['class'] as String;
    final confidence =
        widget.recognitionResult['confidence'] != null
            ? (widget.recognitionResult['confidence'] * 100).toStringAsFixed(2)
            : '0.00';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả nhận dạng'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hiển thị ImagePreview với tên
            ImagePreview(
              imageFile: widget.imageFile,
              vietnameseName:
                  _leafData != null
                      ? _leafData!['vietnameseName']
                      : (_isLoadingLeafData ? 'Đang tải...' : leafName),
              englishName: _leafData != null ? _leafData!['englishName'] : null,
            ),

            // Container thông tin
            _buildResultContainer(leafName, confidence),

            // Các nút hành động
            ActionButtons(
              isSaving: _isSaving,
              isSavedToCollection: _isSavedToCollection,
              isSavedToHistory: _isSavedToHistory,
              onSaveToHistory: _saveToHistory,
              onSaveToCollection: _saveToCollection,
              onRemoveFromCollection: _removeFromCollection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả nhận dạng'),
        backgroundColor: AppColors.appBarColor,
      ),
      body: const Center(child: Text('Không có kết quả nhận dạng')),
    );
  }

  Widget _buildResultContainer(String leafName, String confidence) {
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
          // Tiêu đề
          const Center(
            child: Text(
              'Thông tin về lá thuốc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

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

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Yêu cầu đăng nhập'),
            content: const Text('Bạn cần đăng nhập để lưu kết quả'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Đăng nhập'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenColor,
                ),
              ),
            ],
          ),
    );
  }
}
