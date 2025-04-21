import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart'; // Import AppColors
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_account/account_settings_widget.dart'; // Import AccountSettingsWidget
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_overview/overview_widget.dart'; // Import OverviewWidget
import 'package:medicinal_leaf_scan/navigation/button/logout_button_widget.dart'; // Import LogoutButtonWidget

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
        child: Stack(
          children: [
            // AccountSettingsWidget
            Positioned(
              top: 20,
              left: (MediaQuery.of(context).size.width - 380) / 2,
              child: AccountSettingsWidget(),
            ),

            // OverviewWidget
            Positioned(
              top: 100,
              left: (MediaQuery.of(context).size.width - 380) / 2,
              child: OverviewWidget(),
            ),

            // Logout Button at the bottom
            Align(
              alignment:
                  Alignment
                      .bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 200,
                ), 
                child: LogoutButtonWidget(), // Nút đăng xuất
              ),
            ),
          ],
        ),
      ),
    );
  }
}
