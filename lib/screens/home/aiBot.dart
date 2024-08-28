import 'package:ecoflow/widgets/bottombar.dart';
import 'package:flutter/material.dart';

class Aibot extends StatelessWidget {
  const Aibot({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xFF446DB2),
      body: Stack(
        children: [
          
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomBar(),
          ),
        ],
      ),
    );
  }
}