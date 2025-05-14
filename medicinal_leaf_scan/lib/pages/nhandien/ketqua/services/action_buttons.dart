import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final bool isSaving;
  final bool isSavedToCollection;
  final bool isSavedToHistory;
  final VoidCallback onSaveToHistory;
  final VoidCallback onSaveToCollection;
  final VoidCallback? onRemoveFromCollection;
  
  const ActionButtons({
    Key? key,
    required this.isSaving,
    required this.isSavedToCollection,
    required this.isSavedToHistory,
    required this.onSaveToHistory,
    required this.onSaveToCollection,
    this.onRemoveFromCollection,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Nút lưu vào lịch sử
              ElevatedButton.icon(
                onPressed: isSaving || isSavedToHistory ? null : onSaveToHistory,
                icon: Icon(isSavedToHistory ? Icons.check : Icons.history),
                label: Text(isSavedToHistory ? 'Đã lưu lịch sử' : 'Lưu vào lịch sử'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSavedToHistory 
                      ? Colors.grey 
                      : AppColors.greenColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Nút lưu vào bộ sưu tập
              ElevatedButton.icon(
                onPressed: isSaving || isSavedToCollection 
                    ? null 
                    : onSaveToCollection,
                icon: Icon(isSavedToCollection ? Icons.check : Icons.bookmark),
                label: Text(isSavedToCollection 
                    ? 'Đã lưu vào BST' 
                    : 'Lưu vào BST'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSavedToCollection 
                      ? Colors.grey 
                      : AppColors.greenColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          // Hiển thị nút xóa nếu đã lưu vào bộ sưu tập
          if (isSavedToCollection && onRemoveFromCollection != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: isSaving ? null : onRemoveFromCollection,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Xóa khỏi bộ sưu tập',
                  style: TextStyle(color: Colors.red),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}