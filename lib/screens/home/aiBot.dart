import 'package:ecoflow/widgets/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart'; // JWT 토큰 관련 서비스 임포트

class Aibot extends StatefulWidget {
  const Aibot({super.key});

  @override
  _AibotState createState() => _AibotState();
}

class _AibotState extends State<Aibot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // 사용자 및 AI 메시지 리스트
  bool _isLoading = false; // 로딩 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF446DB2),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 20.0, left: 20, right: 20, bottom: 100),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                    'assets/images/ai.png'), // AI 프로필 사진
                              ),
                              const SizedBox(width: 10),
                            ],
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(10),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.white
                                    : const Color(0xFFE1E1E1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Image.asset('assets/images/Mic_light.png'),
                        iconSize: 30,
                        onPressed: () {
                          // 음성 입력 기능 추가 예정
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'EFLOW에게 무엇이든 물어보세요!',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Image.asset('assets/images/Send.png'),
                        iconSize: 30,
                        onPressed: _sendRequest, // 버튼 클릭 시 요청 전송
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomBar(),
          ),
        ],
      ),
    );
  }

  // API 요청 보내는 함수
  Future<void> _sendRequest() async {
    final String text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });

    final String? token = await getToken(); // JWT 토큰 가져오기

    debugPrint('채팅토큰 $token');

    if (token == null) {
      setState(() {
        _messages.add({'sender': 'ai', 'text': '토큰이 유효하지 않습니다.'});
        _isLoading = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse(
          'http://10.0.2.2:8080/api/text?requestText=$text'), // 텍스트 API 엔드포인트
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final responseData = response.body;
        setState(() {
          _messages.add({'sender': 'ai', 'text': responseData});
          _isLoading = false;
          _controller.clear();
        });
      } catch (e) {
        setState(() {
          _messages
              .add({'sender': 'ai', 'text': '응답 파싱에 실패했습니다: ${e.toString()}'});
          _isLoading = false;
        });
      }
    } else {
      debugPrint('에러 ${response.body}');
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text':
              'AI와의 대화에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}'
        });
        _isLoading = false;
      });
    }
  }
}
