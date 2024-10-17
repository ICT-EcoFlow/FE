import 'package:ecoflow/widgets/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart';
import 'package:ecoflow/models/dto.dart';

class Userupdate extends StatefulWidget {
  const Userupdate({super.key});

  @override
  _UserupdateState createState() => _UserupdateState();
}

class _UserupdateState extends State<Userupdate> {
  // 사용자 정보를 업데이트하는 함수
  Future<void> updateUser(UserResponseDTO user) async {
    final token = await getToken(); // 저장된 JWT 토큰을 가져옴
    final userId = getUserIdFromToken(token!); // ID 추출

    if (userId == null) {
      return; // ID가 없으면 업데이트 중단
    }

    final url = Uri.parse('http://10.0.2.2:8080/api/user/$userId');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token', // JWT 토큰 포함
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': user.username,
        'nickname': user.nickname,
        'car': user.car,
        'carnumber': user.carnumber,
        'password': user.password, // 입력된 비밀번호
        'business': user.business, // 기존의 business 값 사용
      }),
    );

    if (response.statusCode == 200) {
      // 성공적으로 수정되었을 때 스낵바로 안내 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 정보가 성공적으로 업데이트되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // 오류 발생 시 스낵바로 안내 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 정보 업데이트에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 사용자 ID를 JWT에서 추출하여 API 호출
  Future<UserResponseDTO?> getUserById() async {
    final token = await getToken(); // 저장된 JWT 토큰을 가져옴
    final userId = getUserIdFromToken(token!); // ID 추출

    if (userId == null) {
      return null; // ID가 없으면 null 반환
    }

    final url =
        Uri.parse('http://10.0.2.2:8080/api/user/$userId'); // 실제 URL로 변경
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token', // JWT 토큰 포함
    });

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return UserResponseDTO.fromJson(data);
    } else {
      return null; // 오류 처리
    }
  }

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _nicknameController;
  late TextEditingController _carController;
  late TextEditingController _carnumberController;

  @override
  void initState() {
    super.initState();

    // 컨트롤러 초기화
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _nicknameController = TextEditingController();
    _carController = TextEditingController();
    _carnumberController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF446DB2),
      body: Column(
        children: [
          const SizedBox(height: 90), // 상단 여백
          const Center(
            child: Text(
              'ECO FLOW',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: FutureBuilder<UserResponseDTO?>(
              future: getUserById(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // 로딩 중
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('오류 발생: ${snapshot.error}')); // 오류 처리
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                      child: Text('사용자 정보를 찾을 수 없습니다.')); // 사용자 정보 없음
                } else {
                  final user = snapshot.data!;
                  // TextField에 사용자 정보 초기화
                  _usernameController.text = user.username;
                  _nicknameController.text = user.nickname;
                  _carController.text = user.car;
                  _carnumberController.text = user.carnumber;

                  return _buildUserForm(user);
                }
              },
            ),
          ),
          BottomBar(), // 하단 BottomBar
        ],
      ),
    );
  }

  Widget _buildUserForm(UserResponseDTO user) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildTextField('UserName', _usernameController),
          const SizedBox(height: 10),
          _buildTextField('password', _passwordController, obscureText: true),
          const SizedBox(height: 10),
          _buildTextField('nickname', _nicknameController),
          const SizedBox(height: 10),
          _buildTextField('car', _carController),
          const SizedBox(height: 10),
          _buildTextField('carnumber', _carnumberController),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // 사용자의 입력 값을 업데이트 요청
              UserResponseDTO updatedUser = UserResponseDTO(
                id: user.id,
                username: _usernameController.text,
                nickname: _nicknameController.text,
                car: _carController.text,
                carnumber: _carnumberController.text,
                business: user.business, // 기존의 business 상태 유지
                password: _passwordController.text.isNotEmpty
                    ? _passwordController.text
                    : user.password, // 비밀번호 변경되지 않았으면 기존 비밀번호 사용
              );

              updateUser(updatedUser); // 사용자 정보 업데이트 호출
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // 버튼 색상
              padding: const EdgeInsets.symmetric(
                  horizontal: 150, vertical: 15), // 버튼 패딩
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 둥근 버튼
              ),
            ),
            child: const Text(
              'UPDATE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _carController.dispose();
    _carnumberController.dispose();
    super.dispose();
  }
}
