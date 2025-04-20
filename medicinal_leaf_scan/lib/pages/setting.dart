import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';  // Import AppColors
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_overview/overview_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/account_settings_widget.dart';  // Import AccountSettingsWidget


class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 32,
          ),
        ),
        backgroundColor: AppColors.appBarColor,  
        centerTitle: true,  
      ),
      body: Container(
        color: AppColors.bodyColor, 
        child: Stack(
          children: [
            // Thêm widget AccountSettingsWidget vào đây
            Positioned(
              top: 20,  // Khoảng cách từ trên xuống
              left: (MediaQuery.of(context).size.width - 380) / 2,  // Căn giữa theo chiều ngang
              child: AccountSettingsWidget(),
            ),
            // Thêm widget OverviewWidget vào đây
            Positioned(
              top: 100,  // Khoảng cách từ trên xuống
              left: (MediaQuery.of(context).size.width - 380) / 2,  // Căn giữa theo chiều ngang
              child: OverviewWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
