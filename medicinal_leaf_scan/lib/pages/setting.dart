import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';


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
          ],
        ),
      ),
    );
  }
}
