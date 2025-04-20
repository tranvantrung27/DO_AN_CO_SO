import 'package:flutter/material.dart';
import 'package:medicinal_leaf_scan/utils/app_colors.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widget_info/info_widget.dart';
import 'package:medicinal_leaf_scan/widgets/widgets_setting/widgets_using/using_widget.dart';  // Import AppColors

class OverviewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,  
      height: 140,  
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
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          UsingWidget(),
          // 
          Divider(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1), 
            thickness: 1, 
            indent: 15, 
            endIndent: 15, 
          ),
          InfoWidget(),
        ],
      ),
    );
  }
}
