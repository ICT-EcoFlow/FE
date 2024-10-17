import 'package:ecoflow/screens/Map/Usercherger.dart';
import 'package:ecoflow/screens/home/aiBot.dart';
import 'package:ecoflow/screens/home/homepage.dart';
import 'package:ecoflow/screens/mypage/MyPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecoflow/screens/Map/MapScreen.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 0),
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
                      // 다른 화면으로 이동하는 코드 추가 가능
                      Get.to(
                        MyPage(),
                        transition: Transition.noTransition,
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/icons/check.png'),
                    iconSize: 45,
                    onPressed: () {
                      Get.to(
                        Usercherger(key: UniqueKey()),
                        transition: Transition.noTransition,
                      );
                    },
                  ),
                  const SizedBox(width: 63),
                  IconButton(
                    icon: Image.asset('assets/icons/mapIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      Get.to(
                        MapScreen(),
                        transition: Transition.noTransition,
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/icons/aiIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      // Aibot 화면으로 이동
                      Get.to(
                        const Aibot(),
                        transition: Transition.noTransition,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF446DBE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: IconButton(
                icon: Image.asset('assets/icons/elec.png'),
                iconSize: 45,
                onPressed: () {
                  // Homepage로 이동
                  Get.to(
                    Homepage(), // 여기에서 Homepage로 이동하도록 수정
                    transition: Transition.noTransition,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
