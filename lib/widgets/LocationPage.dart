import 'package:flutter/material.dart';

class Locationpage extends StatelessWidget {
  const Locationpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 50,
      decoration: ShapeDecoration(
        color: const Color(0x66446DB2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}
