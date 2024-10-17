import 'package:ecoflow/screens/mypage/PersonalChargerRegistration.dart';
import 'package:ecoflow/widgets/bottombar.dart';
import 'package:ecoflow/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

// 사업자 등록번호로 사업자 상태 조회 API 호출
Future<bool> checkBusinessStatus(String bNo) async {
  final url = Uri.parse('http://10.0.2.2:8080/api/status');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await getToken()}',
    },
    body: json.encode({
      'b_no': [bNo]
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['match_cnt'] > 0;
  } else {
    debugPrint('사업자 등록 상태 조회 오류: ${response.body}');
    return false;
  }
}

// 사업자 상태 업데이트 API 호출
Future<void> updateBusinessStatus(String userId) async {
  final url = Uri.parse('http://10.0.2.2:8080/api/businessupdate/$userId');
  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer ${await getToken()}',
    },
  );

  if (response.statusCode != 200) {
    debugPrint('사업자 상태 업데이트 오류: ${response.body}');
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF446DB2),
      body: Column(
        children: [
          const SizedBox(height: 80), // 상단 여백
          FutureBuilder<UserResponseDTO?>(
            future: getUserById(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // 로딩 중
              } else if (snapshot.hasError) {
                return Text('오류 발생: ${snapshot.error}'); // 오류 처리
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Text('사용자 정보를 찾을 수 없습니다.'); // 사용자 정보 없음
              } else {
                final user = snapshot.data!;
                return _buildCarCard(context, user);
              }
            },
          ),
          const Spacer(),
          BottomBar(),
        ],
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, UserResponseDTO user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.star, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        '주 사용자',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Image.asset(
                      'assets/images/car_image.png', // 자동차 이미지 경로
                      height: 150,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '*대표 이미지',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.car, // 서버에서 받은 자동차 정보 출력
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.carnumber, // 서버에서 받은 자동차 번호 출력
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        user.business == 'x'
                            ? '미신청'
                            : '신청자', // business 상태에 따른 텍스트
                        style: TextStyle(
                          color:
                              user.business == 'x' ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Icon(
                        Icons.warning,
                        color: user.business == 'x' ? Colors.red : Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: user.business == 'o'
                        ? null
                        : () async {
                            final TextEditingController controller =
                                TextEditingController();
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('사업자 등록번호 입력'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                      hintText: '사업자 등록번호를 입력하세요'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      final bNo = controller.text;
                                      final isValid =
                                          await checkBusinessStatus(bNo);
                                      if (isValid) {
                                        await updateBusinessStatus(
                                            user.username);
                                        Navigator.of(context).pop();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  '등록 완료되었습니다. 새로고침 해주세요.')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('올바르지 않은 사업자 등록번호입니다.')),
                                        );
                                      }
                                    },
                                    child: const Text('확인'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('취소'),
                                  ),
                                ],
                              ),
                            );
                          }, // 신청 완료 시 버튼 비활성화
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.business == 'o' ? '사업자 신청완료' : '사업자 신청',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '개인 충전기를 등록 할 수 있습니다.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        IconButton(
                          onPressed: user.business == 'o'
                              ? () {
                                  // + 버튼 눌렀을 때의 동작 정의, business가 'o'일 때만 활성화
                                  // + 버튼 눌렀을 때의 동작 정의
                                  Get.to(
                                    PersonalChargerRegistration(),
                                    transition: Transition.noTransition,
                                  );
                                }
                              : null,
                          icon: Icon(
                            Icons.add_circle,
                            size: 40,
                            color: user.business == 'o'
                                ? Colors.blue
                                : Colors.grey, // 활성화 상태에 따라 색상 변경
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                onPressed: () {
                  // 더보기 버튼 눌렀을 때의 동작 정의
                },
                icon: Image.asset(
                  'assets/images/more_vert.png', // 더보기 아이콘 이미지 경로
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
