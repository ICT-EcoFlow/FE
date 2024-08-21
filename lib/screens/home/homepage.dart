import 'package:ecoflow/widgets/bottombar.dart';
import 'package:ecoflow/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Color(0xFF446DB2),
      body: Stack(
        children: [
          BuildWidget(),
          // DraggableScrollableSheet을 body에 추가
          buildCustomBottomSheet(),
          // BottomBar를 가장 위에 배치
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomBar(),
          ),
        ],
      ),
    );
  }
}

class BuildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 100, 20, 20),
            width: 350,
            height: 100,
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Color(0xFFABABAB),
                      width: 1,
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                Text(
                  '이동국밥 님의 복면차왕',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}