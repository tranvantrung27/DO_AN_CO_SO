import 'package:flutter/material.dart';

class TermsConditionsWidget extends StatelessWidget {
  const TermsConditionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380, 
      height: 60,  
      child: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo Terms and Conditions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Image.asset(
                  'assets/icon/terms-and-conditions.png', 
                  width: 38, 
                  height: 38, 
                ),
              ),
              SizedBox(width: 10),
              // Text "Điều khoản & Điều kiện"
              Expanded(  
                child: Text(
                  'Điều khoản & Điều kiện', 
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Mũi tên ở bên phải
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Icon(
                  Icons.arrow_forward_ios, 
                  size: 25, 
                  color: Colors.black, 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
