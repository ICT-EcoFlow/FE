import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// JWT 토큰 저장
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);
}

// JWT 토큰 읽기
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

// JWT 토큰 삭제
Future<void> deleteToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
}

// JWT에서 사용자 ID 추출하는 함수
String? getUserIdFromToken(String token) {
  try {
    List<String> parts = token.split('.');
    if (parts.length != 3) return null; // 유효한 JWT가 아닙니다.

    String payload = parts[1];
    String normalized = base64Url.normalize(payload);
    String decoded = utf8.decode(base64Url.decode(normalized));

    Map<String, dynamic> jsonMap = json.decode(decoded);
    return jsonMap['sub']; // JSON의 'sub' 필드를 반환
  } catch (e) {
    return null; // 예외 발생 시 null 반환
  }
}
