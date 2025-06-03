// import 'package:flutter/services.dart';

// class LabelsReader {
//   static Map<String, String> modelToFirebaseId = {};
  
//   static Future<void> loadLabelsMapping() async {
//     try {
//       final labelsContent = await rootBundle.loadString('assets/models/labels.txt');
//       final lines = labelsContent.split('\n');
      
//       for (final line in lines) {
//         if (line.trim().isEmpty) continue;
        
//         final parts = line.split('|');
//         if (parts.length >= 2) {
//           final modelLabel = parts[0].trim();
//           final firebaseId = parts[1].trim();
//           modelToFirebaseId[modelLabel] = firebaseId;
//           print('Mapping: $modelLabel => $firebaseId');
//         }
//       }
      
//       print('Đã load ${modelToFirebaseId.length} mappings');
//     } catch (e) {
//       print('Lỗi khi đọc labels.txt: $e');
//     }
//   }
  
//   static String getFirebaseId(String modelLabel) {
//     if (modelLabel.contains('|')) {
//       final parts = modelLabel.split('|');
//       if (parts.length >= 2) {
//         return parts[1].trim();
//       }
//     }
    
//     return modelToFirebaseId[modelLabel] ?? 
//            modelToFirebaseId[modelLabel.toLowerCase()] ??
//            modelLabel.toLowerCase();
//   }
// }