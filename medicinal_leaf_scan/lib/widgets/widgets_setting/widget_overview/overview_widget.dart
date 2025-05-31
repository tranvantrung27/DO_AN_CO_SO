import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_feedback/feedback_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_about/about_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_privacy_policy/privacy_policy_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_terms_conditions/terms_conditions_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_usage/usage_widget.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ô 1: Chứa 2 phần: cách sử dụng và giới thiệu
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(2, 2),
                blurRadius: 5,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            children: [
              // Cách sử dụng
              UsingWidget(),
              Divider(
                color: Colors.black.withOpacity(0.1),
                thickness: 1,
                indent: 15,
                endIndent: 15,
                height: 1, // Giảm chiều cao của divider
              ),
              // Giới thiệu
              InfoWidget(),
            ],
          ),
        ),
        
        const SizedBox(height: 12), // Giảm từ 15 xuống 12
        
        // Ô 2: Chứa 3 phần
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(2, 2),
                blurRadius: 5,
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            children: [
              // Gửi phản hồi
              FeedbackWidget(),
              Divider(
                color: Colors.black.withOpacity(0.1),
                thickness: 1,
                indent: 15,
                endIndent: 15,
                height: 1, // Giảm chiều cao của divider
              ),
              // Chính sách bảo mật
              PrivacyPolicyWidget(),
              Divider(
                color: Colors.black.withOpacity(0.1),
                thickness: 1,
                indent: 15,
                endIndent: 15,
                height: 1, // Giảm chiều cao của divider
              ),
              // Điều khoản & Điều kiện
              TermsConditionsWidget(),
            ],
          ),
        ),
      ],
    );
  }
}