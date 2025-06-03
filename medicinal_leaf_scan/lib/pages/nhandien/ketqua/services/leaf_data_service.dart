import 'package:cloud_firestore/cloud_firestore.dart';
//import '../utils/labels_reader.dart';
import 'package:flutter/material.dart';
class LeafDataService {
  static Future<Map<String, dynamic>?> loadLeafData(String leafId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('medicinal_leaves')
        .where('id', isEqualTo: leafId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
   
      return querySnapshot.docs.first.data();
    }
    print('Debug: Không tìm thấy document cho id=$leafId');
    return null;
  } catch (e) {
    print('Lỗi khi lấy dữ liệu lá thuốc: $e');
    return null;
  }
}

}

class LeafDataCache {
  static final LeafDataCache _instance = LeafDataCache._internal();
  factory LeafDataCache() => _instance;
  LeafDataCache._internal();

  final Map<String, Map<String, dynamic>> _cache = {};

  Future<Map<String, dynamic>?> getLeafData(String leafId) async {
    // Nếu đã có trong cache, trả về ngay lập tức
    if (_cache.containsKey(leafId)) {
      return _cache[leafId];
    }

    // Nếu chưa có, tải và lưu vào cache
    try {
      final data = await LeafDataService.loadLeafData(leafId);
      if (data != null) {
        _cache[leafId] = data;
      }
      return data;
    } catch (e) {
      debugPrint('Error loading leaf data: $e');
      return null;
    }
  }
}