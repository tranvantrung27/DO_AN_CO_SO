import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/account_settings_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_overview/overview_widget.dart';
import 'package:medicinal_leaf_scan/navigation/button/logout_button_widget.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
        ),
        backgroundColor: AppColors.appBarColor,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.bodyColor,
        width: double.infinity,
        child: Column( // Thay SingleChildScrollView bằng Column
          children: [
            Expanded( // Wrap nội dung trong Expanded
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Giảm padding vertical
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Account Settings Widget
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 380),
                      child: AccountSettingsWidget(),
                    ),
                    
                    const SizedBox(height: 12), // Giảm xuống 12
                    
                    // Overview Widget
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 380),
                      child: OverviewWidget(),
                    ),
                    
                    const SizedBox(height: 16), // Giảm xuống 16
                    
                    // Logout Button
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 380),
                      child: LogoutButtonWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}