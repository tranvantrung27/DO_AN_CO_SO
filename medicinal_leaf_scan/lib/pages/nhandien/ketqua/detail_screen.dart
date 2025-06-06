// detail_screen.dart
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      print('Không có tham số hoặc sai kiểu');
      return;
    }

    final leafIdDynamic = args['leafId'];
    if (leafIdDynamic == null) {
      print('leafId null');
      return;
    }
    final String leafId = leafIdDynamic.toString();

    if (args.containsKey('leafData') && args['leafData'] != null) {
      setState(() {
        _leafData = args['leafData'] as Map<String, dynamic>;
        _isLoadingLeafData = false;
      });
    } else {
      final leafData = await LeafDataService.loadLeafData(leafId);
      if (mounted) {
        setState(() {
          _leafData = leafData;
          _isLoadingLeafData = false;
        });
      }
    }

    _checkIfInCollection(leafId);
    _checkIfInHistory(leafId);
  }

  Future<void> _checkIfInCollection(String leafId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
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

  Future<void> _checkIfInHistory(String leafId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
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

  Future<void> _saveToCollection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) return;

    final leafIdDynamic = args['leafId'];
    if (leafIdDynamic == null) return;
    final String leafId = leafIdDynamic.toString();

    final leafName = args['leafName']?.toString() ?? 'Không rõ tên lá';
    final confidenceRaw = args['confidence'];
    final double confidence = (confidenceRaw is double) ? confidenceRaw : 0.0;
    final imageUrl = args['imageUrl']?.toString();

    setState(() => _isSavingToCollection = true);

    try {
      final docRef = await FirebaseFirestore.instance.collection('collections').add({
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

  Future<void> _removeFromCollection() async {
    if (_collectionDocId == null) return;

    setState(() => _isSavingToCollection = true);

    try {
      await FirebaseFirestore.instance.collection('collections').doc(_collectionDocId).delete();

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

  Future<void> _saveToHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) return;

    final leafIdDynamic = args['leafId'];
    if (leafIdDynamic == null) return;
    final String leafId = leafIdDynamic.toString();

    final leafName = args['leafName']?.toString() ?? 'Không rõ tên lá';
    final confidenceRaw = args['confidence'];
    final double confidence = (confidenceRaw is double) ? confidenceRaw : 0.0;
    final imageUrl = args['imageUrl']?.toString();

    setState(() => _isSavingToHistory = true);

    try {
      await FirebaseFirestore.instance.collection('history').add({
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết lá')),
        body: const Center(child: Text('Không có dữ liệu để hiển thị')),
      );
    }

    final leafName = args['leafName']?.toString() ?? 'Không rõ tên lá';
    final confidenceRaw = args['confidence'];
    final confidence = (confidenceRaw is double) ? confidenceRaw : 0.0;
    final imageUrl = args['imageUrl']?.toString();

    return Scaffold(
      backgroundColor: AppColors.appBarColor,
      appBar: AppBar(
        title: const Text('Chi tiết lá'),
        backgroundColor: AppColors.appBarColor,
        actions: [
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
                  tooltip: _isSavedToCollection ? 'Xóa khỏi bộ sưu tập' : 'Lưu vào bộ sưu tập',
                  onPressed: _isSavedToCollection ? _removeFromCollection : _saveToCollection,
                ),
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
                  onPressed: _isSavedToHistory ? null : _saveToHistory,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImagePreview(imageUrl, leafName),
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
          Center(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(color: AppColors.greenColor),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.eco,
                      size: 80,
                      color: AppColors.greenColor.withOpacity(0.5),
                    ),
                  )
                : Icon(Icons.eco, size: 80, color: AppColors.greenColor),
          ),
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
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leafName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
    (confidence * 100).toStringAsFixed(1);

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
          const Center(
            child: Text('Thông tin về lá thuốc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          if (_isLoadingLeafData)
            const Center(child: CircularProgressIndicator())
          else if (_leafData == null)
            const Text('Không tìm thấy thông tin chi tiết về loại lá này.', style: TextStyle(fontSize: 16, color: Colors.grey))
          else
            LeafInfoWidget(leafData: _leafData!),
        ],
      ),
    );
  }
}
