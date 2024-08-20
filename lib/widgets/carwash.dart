import 'package:flutter/material.dart';

class Carwash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 340,
          height: 110,
          decoration: ShapeDecoration(
            color: Color(0x66446DB2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5, left: 15),
              ),
              Column(
                children: [
                  // Top-right small image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/icons/shinecar.png', // 파일 확장자를 포함
                        width: 110,
                        height: 80,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 12.0),
                          child: Text(
                            '오늘은 세차하기 좋은 날 :)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Pretendard Variable',
                              fontWeight: FontWeight.w400,
                              height: 0.08,
                              letterSpacing: -0.50,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),              
            ],
          ),
        ),
      ],
    );
  }
}
