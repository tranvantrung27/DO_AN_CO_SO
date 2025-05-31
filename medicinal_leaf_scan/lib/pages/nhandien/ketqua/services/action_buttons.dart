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
              // Nút lưu vào lịch sử - giữ nguyên
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
              
              // Nút lưu hoặc xóa BST (thay đổi ở đây)
              ElevatedButton.icon(
                onPressed: isSaving 
                    ? null 
                    : (isSavedToCollection 
                        ? onRemoveFromCollection 
                        : onSaveToCollection),
                icon: Icon(isSavedToCollection 
                    ? Icons.delete_outline 
                    : Icons.bookmark),
                label: Text(isSavedToCollection 
                    ? 'Xóa khỏi BST' 
                    : 'Lưu vào BST'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSavedToCollection 
                      ? Colors.red 
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
          // Xóa phần nút xóa ở dưới vì đã gộp chức năng vào nút chính
        ],
      ),
    );
  }
}