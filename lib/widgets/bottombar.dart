import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 및 나머지 아이콘들
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width, // 가로 전체 너비 설정
              height: 70, // BottomBar의 높이 설정
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(0, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Image.asset('assets/icons/carIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      // 버튼을 눌렀을 때의 동작
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/icons/cardIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      // 버튼을 눌렀을 때의 동작
                    },
                  ),
                  SizedBox(width: 63), // 가운데 원형 컨테이너를 위한 공간 확보
                  IconButton(
                    icon: Image.asset('assets/icons/mapIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      // 버튼을 눌렀을 때의 동작
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/icons/aiIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      // 버튼을 눌렀을 때의 동작
                    },
                  ),
                ],
              ),
            ),
          ),
          // 가운데 위치한 원형 컨테이너와 elec 아이콘
          Positioned(
            bottom: 25, // BottomBar에서 50만큼 떨어지도록 설정
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF446DBE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(0, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: IconButton(
                icon: Image.asset('assets/icons/elec.png'),
                iconSize: 45,
                onPressed: () {
                  // 버튼 클릭 시 동작
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
