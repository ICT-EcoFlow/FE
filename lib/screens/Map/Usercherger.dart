import 'package:ecoflow/widgets/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart';

class Usercherger extends StatefulWidget {
  const Usercherger({super.key});

  @override
  _UserchergerState createState() => _UserchergerState();
}

class _UserchergerState extends State<Usercherger> {
  List<dynamic> userChargers = [];

  @override
  void initState() {
    super.initState();
    fetchUserChargers();
  }

  Future<void> fetchUserChargers() async {
    final token = await getToken();
    final userId = getUserIdFromToken(token!);
    if (userId == null) return;

    final url = Uri.parse('http://10.0.2.2:8080/api/usercherger/$userId');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        userChargers = data;
      });
    } else {
      debugPrint('Failed to load chargers: ${response.body}');
    }
  }

  Future<void> updateChargerStat(int id) async {
    final token = await getToken();
    final url =
        Uri.parse('http://10.0.2.2:8080/api/usercherger/updateStat/$id');
    final response = await http.put(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      fetchUserChargers(); // 상태 변경 후 다시 데이터 로드
    } else {
      debugPrint('Failed to update charger stat: ${response.body}');
    }
  }

  Future<void> deleteUserchergerById(int id) async {
    final token = await getToken();
    final url = Uri.parse('http://10.0.2.2:8080/api/usercherger/delete/$id');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      fetchUserChargers(); // 삭제 후 다시 데이터 로드
    } else {
      debugPrint('Failed to delete charger: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: Color(0xFF446DB2),
      body: Column(
        children: [
          SizedBox(height: 60),
          Text(
            'ECO FLOW',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '개인 충전기 관리 화면',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                itemCount: userChargers.length,
                itemBuilder: (context, index) {
                  final charger = userChargers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.purple,
                          child: Text(
                            charger['username'][0],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            charger['statNm'],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => updateChargerStat(charger['id']),
                          child: Image.asset(
                            charger['stat'] == '2'
                                ? 'assets/images/on.png'
                                : 'assets/images/off.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => deleteUserchergerById(charger['id']),
                          child: Image.asset(
                            'assets/images/trash.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        SizedBox(width: 15),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '충전기를 추가 등록하실 수 있습니다.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomBar(),
          ),
        ],
      ),
    );
  }
}
