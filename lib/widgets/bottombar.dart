import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Container(
      width: screenWidth,  // screenWidth로 컨테이너 너비 설정
      height: 90,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 14,
            child: Container(
              width: screenWidth,  // screenWidth로 컨테이너 너비 설정
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(0, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 95,
                    top: 10,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/icons/carIcon.png', // 아이콘 경로
                      ),
                      iconSize: 45, // 아이콘 크기 (선택 사항)
                      onPressed: () {
                        // 버튼을 눌렀을 때의 동작
                      },
                    ),
                  ),
                  Positioned(
                    left: 25,
                    top: 12,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/icons/cardIcon.png', // 아이콘 경로
                      ),
                      iconSize: 45.0, // 아이콘 크기 (선택 사항)
                      onPressed: () {
                        // 버튼을 눌렀을 때의 동작
                      },
                    ),
                  ),
                  Positioned(
                    left: 240,
                    top: 10,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/icons/mapIcon.png', // 아이콘 경로
                      ),
                      iconSize: 45.0, // 아이콘 크기 (선택 사항)
                      onPressed: () {
                        // 버튼을 눌렀을 때의 동작
                      },
                    ),
                  ),
                  Positioned(
                    left: 310,
                    top: 10,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/icons/aiIcon.png', // 아이콘 경로
                      ),
                      iconSize: 45, // 아이콘 크기 (선택 사항)
                      onPressed: () {
                        // 버튼을 눌렀을 때의 동작
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: screenWidth / 2 - 31.5, // 화면 가운데에 배치
            top: 0,
            child: Container(
              width: 63,
              height: 63,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 63,
                      height: 63,
                      decoration: ShapeDecoration(
                        color: Color(0xFF446DB2),
                        shape: OvalBorder(
                          side: BorderSide(width: 1, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 2.52,
                    top: 2.52,
                    child: Container(
                      width: 60,
                      height: 60,
                      
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: IconButton(
                        icon: Image.asset('assets/icons/elec.png'),
                        onPressed: () {
                          // 버튼 클릭 시 동작을 여기에 추가하세요
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
