import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';

import '../../../../services/mailjet_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final MailjetService mailjetService = MailjetService(
    '09db93747b2bf0788e3e118fbfacb8fe',  // API Key
    '87c3c843a61ae26205713406e5adec89',  // Secret Key
  ); // Secret Key

  final _formKey = GlobalKey<FormState>();
  
  String fullName = '';
  String email = '';
  String feedbackContent = '';
  bool isLoading = false;
  Map<String, dynamic>? feedbackFormData;

  @override
  void initState() {
    super.initState();
    _loadFeedbackFormData();
  }

  Future<void> _loadFeedbackFormData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_info')
          .doc('feedback')
          .get();

      if (doc.exists) {
        setState(() {
          feedbackFormData = doc.data();
        });
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu feedback form: $e');
    }
  }

  Future<void> _submitFeedback() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  setState(() {
    isLoading = true;
  });

  try {
    // 1. Lưu phản hồi lên Firestore
    await FirebaseFirestore.instance.collection('feedbacks').add({
      'full_name': fullName,
      'email': email,
      'content': feedbackContent,
      'created_at': Timestamp.now(),
    });

    // 2. Gửi email cảm ơn qua Mailjet
    final emailSent = await mailjetService.sendEmail(
      fromEmail: 'trantrung04.contact@gmail.com', 
      toEmail: email,
      subject: 'Cảm ơn bạn đã gửi phản hồi',
      content:
          'Xin chào $fullName,\n\nCảm ơn bạn đã gửi phản hồi tới chúng tôi.\n\nTrân trọng,\nĐội ngũ hỗ trợ',
    );

    setState(() {
      isLoading = false;
    });

    if (emailSent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn đã gửi phản hồi!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi email thất bại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gửi phản hồi thất bại: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    final title = feedbackFormData?['title'] ?? 'Gửi phản hồi cho chúng tôi';
    final description = feedbackFormData?['description'] ?? '';
    final fields = feedbackFormData?['form']?['fields'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: AppColors.bodyColor,
      appBar: AppBar(
        title: const Text('Phản hồi'),
        backgroundColor: AppColors.appBarColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: feedbackFormData == null
          ? const LoadingWidget()
          : ContentWidget(
              title: title,
              description: description,
              fields: fields,
              formKey: _formKey,
              isLoading: isLoading,
              onSubmit: _submitFeedback,
              onSave: _handleSave,
            ),
    );
  }

  void _handleSave(String label, String? value) {
    final loweredLabel = label.toLowerCase();
    if (loweredLabel.contains('họ') || loweredLabel.contains('tên')) {
      fullName = value?.trim() ?? '';
    } else if (loweredLabel == 'email') {
      email = value?.trim() ?? '';
    } else if (loweredLabel.contains('nội dung')) {
      feedbackContent = value?.trim() ?? '';
    }
  }
}

// Widget loading
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải form...'),
        ],
      ),
    );
  }
}

// Widget nội dung chính
class ContentWidget extends StatelessWidget {
  final String title;
  final String description;
  final List<dynamic> fields;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;
  final Function(String, String?) onSave;

  const ContentWidget({
    super.key,
    required this.title,
    required this.description,
    required this.fields,
    required this.formKey,
    required this.isLoading,
    required this.onSubmit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderCard(title: title, description: description),
          const SizedBox(height: 20),
          FormCard(
            formKey: formKey,
            fields: fields,
            isLoading: isLoading,
            onSubmit: onSubmit,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}

// Widget header card
class HeaderCard extends StatelessWidget {
  final String title;
  final String description;

  const HeaderCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.feedback,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget form card
class FormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<dynamic> fields;
  final bool isLoading;
  final VoidCallback onSubmit;
  final Function(String, String?) onSave;

  const FormCard({
    super.key,
    required this.formKey,
    required this.fields,
    required this.isLoading,
    required this.onSubmit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin phản hồi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ...fields.map((field) {
                return FormFieldWidget(
                  field: field,
                  onSave: onSave,
                );
              }).toList(),
              const SizedBox(height: 10),
              SubmitButton(isLoading: isLoading, onSubmit: onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget field trong form
class FormFieldWidget extends StatelessWidget {
  final dynamic field;
  final Function(String, String?) onSave;

  const FormFieldWidget({
    super.key,
    required this.field,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final label = field['label'] ?? '';
    final type = field['type'] ?? 'text';
    final requiredField = field['required'] ?? false;
    final placeholder = field['placeholder'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: type == 'email'
            ? TextInputType.emailAddress
            : TextInputType.text,
        maxLines: type == 'textarea' ? 5 : 1,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
          ),
          prefixIcon: _getIcon(type),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return 'Trường này không được để trống';
          }
          if (type == 'email' && value != null && value.isNotEmpty) {
            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegex.hasMatch(value)) {
              return 'Email không hợp lệ';
            }
          }
          return null;
        },
        onSaved: (value) => onSave(label, value),
      ),
    );
  }

  Icon? _getIcon(String type) {
    switch (type) {
      case 'email':
        return Icon(Icons.email_outlined, color: Colors.grey[600]);
      case 'textarea':
        return Icon(Icons.message_outlined, color: Colors.grey[600]);
      default:
        return Icon(Icons.person_outline, color: Colors.grey[600]);
    }
  }
}

// Widget nút submit
class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text(
                    'Gửi phản hồi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}