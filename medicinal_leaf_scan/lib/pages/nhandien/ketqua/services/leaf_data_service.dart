import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/labels_reader.dart';

class LeafDataService {
  static Future<Map<String, dynamic>?> loadLeafData(String recognitionClass) async {
    try {
      print('Model label từ nhận diện: $recognitionClass');
      
      String firebaseId = LabelsReader.getFirebaseId(recognitionClass);
      print('Firebase ID sau khi xử lý: $firebaseId');
      
      // Query theo ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('medicinal_leaves')
          .where('id', isEqualTo: firebaseId)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        print('Tìm thấy dữ liệu lá thuốc!');
        return querySnapshot.docs.first.data();
      }
      
      // Thử tìm bằng englishName
      final modelName = recognitionClass.split('|')[0];
      final englishNameQuery = await FirebaseFirestore.instance
          .collection('medicinal_leaves')
          .where('englishName', isEqualTo: modelName)
          .limit(1)
          .get();
          
      if (englishNameQuery.docs.isNotEmpty) {
        return englishNameQuery.docs.first.data();
      }
      
      return null;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu lá thuốc: $e');
      return null;
    }
  }
}