import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:ecoflow/screens/accounts/RegisterResult.dart';
import 'package:ecoflow/models/dto.dart'; // DTO 파일 경로
import 'package:ecoflow/screens/home/homepage.dart'; // 홈 화면 경로
import 'package:ecoflow/services/token_storage.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  Future<void> login(String username, String password) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
          LoginRequestDTO(username: username, password: password).toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      LoginResponseDTO loginResponse = LoginResponseDTO.fromJson(responseData);

      if (loginResponse.status == 'Success') {
        // JWT 토큰 저장
        await saveToken(loginResponse.token ?? ''); // 토큰이 null일 경우 빈 문자열로 저장
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        showSnackBar(context, Text('로그인 실패: ${loginResponse.status}'));
      }
    } else {
      showSnackBar(context, const Text('서버와 연결할 수 없습니다.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Background.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 160),
                    child: Center(
                      child: Text(
                        '나를 위한\n나의 전기차를 위한',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Form(
                    child: Theme(
                      data: ThemeData(
                        primaryColor: Colors.grey,
                        inputDecorationTheme: const InputDecorationTheme(
                          labelStyle: TextStyle(
                            color: Colors.teal,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(40.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '아이디',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 316,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                child: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: '이메일을 입력해주세요.',
                                    labelStyle: TextStyle(
                                      color: const Color(0xFF555555)
                                          .withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '비밀번호',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 316,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                child: TextField(
                                  controller: controller2,
                                  decoration: InputDecoration(
                                    labelText: '비밀번호를 입력하세요.',
                                    labelStyle: TextStyle(
                                      color: const Color(0xFF555555)
                                          .withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                  ),
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                ),
                              ),
                              const SizedBox(height: 40.0),
                              ButtonTheme(
                                minWidth: 100.0,
                                height: 50.0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (controller.text.isNotEmpty &&
                                        controller2.text.isNotEmpty) {
                                      login(controller.text,
                                          controller2.text); // 로그인 요청
                                    } else {
                                      showSnackBar(context,
                                          const Text('아이디와 비밀번호를 입력하세요.'));
                                    }
                                  },
                                  child: const Text('로그인'),
                                ),
                              ),
                            ],
                          ),
                        ),
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

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: const Color.fromARGB(225, 112, 48, 48),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
