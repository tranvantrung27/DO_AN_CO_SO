import 'package:flutter/material.dart';

class NavigationIcons extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavigationIcons({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(26, 69, 14, 14),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: 'assets/logo_navigation/history_icon.png',
              label: 'History',
              isSelected: selectedIndex == 0,
            ),
            const SizedBox(width: 80),
            _buildNavItem(
              index: 2,
              icon: 'assets/logo_navigation/setting_icon.png',
              label: 'Setting',
              isSelected: selectedIndex == 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.green : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
