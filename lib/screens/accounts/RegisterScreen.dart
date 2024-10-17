import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/screens/accounts/RegisterResult.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController carController = TextEditingController();
  TextEditingController carNicknameController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();

  Future<void> registerUser() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/signup');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_jwt_token_here', // JWT 토큰 수정 필요
      },
      body: json.encode({
        "username": usernameController.text,
        "password": passwordController.text,
        "nickname": nicknameController.text,
        "car": carController.text,
        "carnickname": carNicknameController.text,
        "phone": phonenumberController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true) {
        Get.to(() => RegisterResult(), transition: Transition.rightToLeft);
      } else {
        showSnackBar(context, Text('회원가입 실패: ${responseData['message']}'));
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
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: Text(
                        '회원 가입',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildInputField(
                                  '아이디', '이메일을 입력해주세요.', usernameController),
                              buildInputField(
                                  '비밀번호', '비밀번호를 입력해주세요.', passwordController,
                                  isPassword: true),
                              buildInputField('핸드폰 번호', '핸드폰 번호를 입력해주세요.',
                                  phonenumberController),
                              buildInputField(
                                  '닉네임', '닉네임을 입력해주세요.', nicknameController),
                              buildInputField(
                                  '차종', '차종을 입력해주세요.', carController),
                              buildInputField(
                                  '차 번호', '내 차 번호', carNicknameController),
                              const SizedBox(height: 40.0),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (usernameController.text.isNotEmpty &&
                                        passwordController.text.isNotEmpty &&
                                        nicknameController.text.isNotEmpty &&
                                        carController.text.isNotEmpty &&
                                        carNicknameController.text.isNotEmpty &&
                                        phonenumberController.text.isNotEmpty) {
                                      registerUser(); // 회원가입 요청
                                    } else {
                                      showSnackBar(context,
                                          const Text('모든 필드를 입력해주세요.'));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 120, vertical: 15),
                                    textStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  child: const Text('회원가입 하기'),
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

  Widget buildInputField(
      String label, String hint, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: 370,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: hint,
                labelStyle: TextStyle(
                  color: const Color(0xFF555555).withOpacity(0.7),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              obscureText: isPassword,
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
