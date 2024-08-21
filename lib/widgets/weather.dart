import 'package:flutter/material.dart';

class Weather extends StatelessWidget {
  const Weather({super.key});
  @override
    Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 510,
      decoration: BoxDecoration(
      shape: BoxShape.rectangle, // RoundedRectangleBorder로도 가능
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          Color(0x66446DB2), // 40%의 #446DB2
          Color(0xFF3352F8), // 100%의 #3352F8
        ],
        begin: Alignment.topCenter,   // 0% 위치
        end: Alignment.bottomCenter,  // 100% 위치
      ),
    ),
      child: Column(
        // api 받아서 요소 넣기
      ),
    );
  }
}