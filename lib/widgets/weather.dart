import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart'; // JWT 토큰 관련 서비스 임포트
import 'package:ecoflow/models/dto.dart';

class Weather extends StatelessWidget {
  const Weather({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0x66446DB2), // 40%의 #446DB2
            Color(0xFF3352F8), // 100%의 #3352F8
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FutureBuilder<WeatherDTO>(
        future: fetchWeeklyWeather(), // API 호출 함수
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중
          } else if (snapshot.hasError) {
            return const Center(child: Text('날씨 정보를 가져오는 데 실패했습니다.')); // 오류 처리
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('날씨 정보를 찾을 수 없습니다.')); // 사용자 정보 없음
          } else {
            return Column(
              children: [
                const Text('이번 주 날씨',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
                const SizedBox(height: 20),
                ...snapshot.data!.forecastDays
                    .map((day) => _buildWeatherCard(day)), // 각 날씨 카드 생성
              ],
            );
          }
        },
      ),
    );
  }

  // API 호출 함수
  Future<WeatherDTO> fetchWeeklyWeather() async {
    final token = await getToken(); // JWT 토큰을 가져옴
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/weather/weekly'), // 실제 API URL로 변경
      headers: {
        'Authorization': 'Bearer $token', // JWT 토큰 포함
      },
    );

    if (response.statusCode == 200) {
      return WeatherDTO.fromJson(json.decode(response.body)); // JSON 응답 반환
    } else {
      throw Exception('Failed to load weather'); // 오류 발생 시 예외 던짐
    }
  }

  // 날씨 카드 생성
  Widget _buildWeatherCard(WeatherDay day) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // 배경 색상
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day.date, style: const TextStyle(color: Colors.white)),
              Text('${day.minTemp} / ${day.maxTemp}',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
          Image.network('http:${day.conditionIcon}',
              width: 50, height: 50), // 날씨 아이콘
        ],
      ),
    );
  }
}
