import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart'; // JWT 토큰 관련 서비스 임포트

class Carwash extends StatelessWidget {
  const Carwash({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchCarWashRecommendation(), // API 호출 함수
      builder: (context, snapshot) {
        String recommendationText = '오늘은 세차하기 좋은 날 :)'; // 기본 텍스트

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 로딩 중
        } else if (snapshot.hasError) {
          recommendationText = '날씨 정보를 가져오는 데 실패했습니다.'; // 오류 처리
        } else if (snapshot.hasData) {
          recommendationText = snapshot.data!['recommendation'] ??
              recommendationText; // API 응답으로 업데이트
        }

        return Column(
          children: [
            Container(
              width: 340,
              height: 110,
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
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5, left: 15),
                  ),
                  Expanded(
                    // Expanded 위젯을 사용하여 Row의 자식 요소에 공간 분배
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/icons/shinecar.png', // 파일 확장자를 포함
                          width: 120,
                          height: 90,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 12.0),
                          child: Text(
                            recommendationText, // API 응답에 따라 텍스트 업데이트
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'Pretendard Variable',
                              fontWeight: FontWeight.w400,
                              height: 0.08,
                              letterSpacing: -0.50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // API 호출 함수
  Future<Map<String, dynamic>> fetchCarWashRecommendation() async {
    final token = await getToken(); // JWT 토큰을 가져옴
    debugPrint('세차 토큰: $token');

    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:8080/api/weather/carWashRecommendation'), // 실제 API URL로 변경
      headers: {
        'Authorization': 'Bearer $token', // JWT 토큰 포함
      },
    );

    if (response.statusCode == 200) {
      debugPrint('응답 본문: ${response.body}'); // 응답 본문 출력
      return json.decode(utf8.decode(response.bodyBytes)); // JSON 응답 반환
    } else {
      throw Exception('Failed to load recommendation'); // 오류 발생 시 예외 던짐
    }
  }
}
