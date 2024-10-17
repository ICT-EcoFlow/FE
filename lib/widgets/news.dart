import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart'; // JWT 토큰 관련 서비스 임포트
import 'package:ecoflow/models/dto.dart'; // DTO 파일의 경로를 올바르게 수정하세요
import 'package:url_launcher/url_launcher.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 500,
      decoration: BoxDecoration(
        color: const Color(0x66446DB2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<List<NewsDTO>>(
        future: fetchNews(), // 뉴스 정보를 가져오기 위한 FutureBuilder
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중
          } else if (snapshot.hasError) {
            return const Center(child: Text('뉴스 정보를 가져오는 데 실패했습니다.')); // 오류 처리
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('뉴스 정보를 찾을 수 없습니다.')); // 데이터 없음
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final newsItem = snapshot.data![index];
                return _buildNewsItem(newsItem);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildNewsItem(NewsDTO news) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              news.description,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              news.pubDate,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: () => _launchURL(news.link), // 링크 클릭 시 웹 브라우저로 이동
              child: const Text(
                '자세히 보기',
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    debugPrint('Launching URL: $url'); // 로그 출력
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

Future<List<NewsDTO>> fetchNews() async {
  final token = await getToken(); // JWT 토큰을 가져옴
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8080/api/news'), // 실제 API URL로 변경
    headers: {
      'Authorization': 'Bearer $token', // JWT 토큰 포함
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonList =
        json.decode(utf8.decode(response.bodyBytes)); // JSON 응답을 리스트로 변환
    return jsonList
        .map((json) => NewsDTO.fromJson(json))
        .toList(); // DTO 리스트로 변환
  } else {
    throw Exception('Failed to load news'); // 오류 발생 시 예외 던짐
  }
}
