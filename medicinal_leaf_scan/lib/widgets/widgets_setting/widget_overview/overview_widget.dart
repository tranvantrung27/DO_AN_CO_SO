import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_feedback/feedback_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_info/info_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_privacy_policy/privacy_policy_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_terms_conditions/terms_conditions_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_using/using_widget.dart';

class OverviewWidget extends StatelessWidget {
  const OverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,  
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Ô 1: Chứa 2 phần: cách sử dụng và giới thiệu
            Container(
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
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // cách sử dụng
                  UsingWidget(),
                  Divider(
                    color: Colors.black.withOpacity(0.1),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  // giới thiệu
                  InfoWidget(),
                ],
              ),
            ),
            // Ô 2: Chứa 3 phần:Gửi phản hồi, Chính sách bảo mật, Điều khoản & Điều kiện
            Container(
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
              margin: EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Gửi phản hồi
                  FeedbackWidget(),
                  Divider(
                    color: Colors.black.withOpacity(0.1),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  // Chính sách bảo mật
                  PrivacyPolicyWidget(),
                  Divider(
                    color: Colors.black.withOpacity(0.1),
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  ),
                  // Điều khoản & Điều kiện
                  TermsConditionsWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
