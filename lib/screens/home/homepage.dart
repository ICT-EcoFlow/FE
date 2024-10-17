import 'package:ecoflow/widgets/bottombar.dart';
import 'package:ecoflow/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:ecoflow/models/dto.dart';
import 'package:ecoflow/services/token_storage.dart';

// 사용자 ID를 JWT에서 추출하여 API 호출
Future<UserResponseDTO?> getUserById() async {
  final token = await getToken(); // 저장된 JWT 토큰을 가져옴
  debugPrint('토큰 출력: $token'); // 토큰을 출력합니다.

  final userId = getUserIdFromToken(token!); // ID 추출
  debugPrint('아이디 출력: $userId'); // 여기서 ID를 출력합니다.

  if (userId == null) {
    debugPrint('사용자 ID가 null입니다.'); // 사용자 ID가 null일 때 로그 출력
    return null; // ID가 없으면 null 반환
  }

  final url = Uri.parse('http://10.0.2.2:8080/api/user/$userId'); // 실제 URL로 변경
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token', // JWT 토큰 포함
  });

  debugPrint('API 호출 결과: ${response.statusCode}'); // API 호출의 상태 코드 출력

  if (response.statusCode == 200) {
    final data = json.decode(utf8.decode(response.bodyBytes));
    return UserResponseDTO.fromJson(data);
  } else {
    debugPrint('API 오류: ${response.body}'); // 오류 발생 시 API 응답 로그 출력
    return null; // 오류 처리
  }
}

// 현재 위치를 가져오는 함수
Future<Position> _getCurrentLocation() async {
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

// AiMap2 API를 호출하여 데이터를 받아오는 함수
Future<String?> getAiMapData(double lat, double lng) async {
  final token = await getToken();
  final url = Uri.parse('http://10.0.2.2:8080/api/AiMap2?lat=$lat&lng=$lng');
  final response = await http.post(url, headers: {
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    return utf8.decode(response.bodyBytes); // 데이터를 받아서 반환
  } else {
    return null; // 오류 처리
  }
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF446DB2),
      body: Stack(
        children: [
          BuildWidget(), // BuildWidget 호출
          buildCustomBottomSheet(),
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
    return Column(
      children: [
        // 사용자 정보를 상단에 배치
        FutureBuilder<UserResponseDTO?>(
          future: getUserById(), // 사용자 정보를 가져오기 위한 FutureBuilder
          builder: (context, snapshot) {
            String nickname = '??'; // 기본 닉네임

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // 로딩 중
            } else if (snapshot.hasError) {
              return Text('오류 발생: ${snapshot.error}'); // 오류 처리
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Text('사용자 정보를 찾을 수 없습니다.'); // 사용자 정보 없음
            } else {
              final user = snapshot.data!;
              nickname = user.nickname; // 서버에서 받은 닉네임으로 업데이트
            }

            return Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10, 50, 20, 20), // 여백 조정
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
                      SizedBox(width: 20),
                      Text(
                        '$nickname 님', // 닉네임 출력
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black, fontSize: 24), // 스타일 적용
                      ),
                    ],
                  ),
                ),
                FutureBuilder<String?>(
                  future: _getCurrentLocation().then((position) {
                    return getAiMapData(position.latitude,
                        position.longitude); // 위치 정보를 API로 전송
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 로딩 중
                    } else if (snapshot.hasError) {
                      return Text(
                          '데이터를 불러오는 중 오류 발생: ${snapshot.error}'); // 오류 처리
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text('위치 정보를 찾을 수 없습니다.'); // 데이터 없음
                    } else {
                      return Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white, // 배경색
                          borderRadius: BorderRadius.circular(10), // 둥근 테두리
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'AI 추천 충전소 정보',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 15),
                            Image.asset(
                              'assets/images/ai.png', // 이미지 경로
                              width: 100,
                              height: 100,
                            ),
                            SizedBox(height: 15),
                            Text(
                              snapshot.data!, // 데이터를 표시
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
        // 추가 콘텐츠를 여기에 배치 (예: 아래 카드)
        // 추가 콘텐츠를 여기에 배치 (예: 아래 카드)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(),
              // 다른 콘텐츠 추가 가능
            ],
          ),
        ),
      ],
    );
  }
}
