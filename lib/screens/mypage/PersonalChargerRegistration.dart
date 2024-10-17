import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // 추가

class PersonalChargerRegistration extends StatefulWidget {
  const PersonalChargerRegistration({super.key});

  @override
  _PersonalChargerRegistrationState createState() =>
      _PersonalChargerRegistrationState();
}

class _PersonalChargerRegistrationState
    extends State<PersonalChargerRegistration> {
  final TextEditingController statNmController = TextEditingController();
  final TextEditingController busiCallController = TextEditingController();
  final TextEditingController useTimeController = TextEditingController();
  final TextEditingController addrController = TextEditingController();
  final TextEditingController chargeController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  String chegerType = 'DC차데모';

  void _searchAddress(BuildContext context) async {
    KopoModel? model = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RemediKopo(),
      ),
    );

    if (model != null) {
      setState(() {
        addrController.text = model.address ?? '';
      });
      _getCoordinatesFromAddress(model.address ?? '');
    } else {
      Get.snackbar('오류', '주소 검색에 실패했습니다.');
    }
  }

  void _getCoordinatesFromAddress(String address) async {
    final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/address.json?query=$address');
    final response = await http.get(url, headers: {
      'Authorization': 'KakaoAK 4e3bd43944faf274443700808cba2820',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['documents'].isNotEmpty) {
        final lat = data['documents'][0]['y'];
        final lng = data['documents'][0]['x'];
        setState(() {
          latController.text = lat;
          lngController.text = lng;
        });
      }
    } else {
      Get.snackbar('오류', '좌표 검색에 실패했습니다.');
    }
  }

  Future<void> _registerCharger() async {
    final token = await getToken();
    final chegerTypeNumber = _mapChargerTypeToNumber(chegerType);
    // JWT에서 사용자 ID 추출
    final username = getUserIdFromToken(token!); // ID 추출

    if (username == null) {
      // 유효하지 않은 토큰 처리
      print('유효하지 않은 토큰입니다.');
      return;
    }

    final body = jsonEncode({
      "username": username, // 토큰에서 추출한 username 사용
      "statNm": statNmController.text,
      "addr": addrController.text,
      "lat": latController.text,
      "lng": lngController.text,
      "useTime": useTimeController.text,
      "busiCall": busiCallController.text,
      "chgerType": chegerTypeNumber,
      "stat": null,
      "id": null,
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/usercherger/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      Get.snackbar('등록', '개인 충전기 등록 완료!');
    } else {
      Get.snackbar('오류', '충전기 등록에 실패했습니다.');
    }
  }

  int _mapChargerTypeToNumber(String type) {
    switch (type) {
      case 'DC차데모':
        return 01;
      case 'AC완속':
        return 02;
      case 'DC차데모+AC3상':
        return 03;
      case 'DC콤보':
        return 04;
      case 'DC차데모+DC콤보':
        return 05;
      case 'DC차데모+AC3상+DC콤보':
        return 06;
      case 'AC3상':
        return 07;
      case 'DC콤보(완속)':
        return 08;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF446DB2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF446DB2),
        elevation: 0,
        title: const Text(
          'ECO FLOW',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('StatNm', '충전소 이름', statNmController),
              const SizedBox(height: 16),
              _buildTextField('BusiCall', '핸드폰 번호', busiCallController),
              const SizedBox(height: 16),
              _buildTextField('UseTime', '이용가능 시간', useTimeController),
              const SizedBox(height: 16),
              _buildChegerTypeDropdown(),
              const SizedBox(height: 16),
              _buildAddressField(context),
              const SizedBox(height: 16),
              _buildTextField('Latitude', '위도', latController, readOnly: true),
              const SizedBox(height: 16),
              _buildTextField('Longitude', '경도', lngController, readOnly: true),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _registerCharger,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller,
      {bool readOnly = false}) {
    Color fillColor = readOnly ? Colors.grey[200]! : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
          readOnly: readOnly,
        ),
      ],
    );
  }

  Widget _buildChegerTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ChegerType',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: chegerType,
          items: [
            'DC차데모',
            'AC완속',
            'DC차데모+AC3상',
            'DC콤보',
            'DC차데모+DC콤보',
            'DC차데모+AC3상+DC콤보',
            'AC3상',
            'DC콤보(완속)'
          ].map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              chegerType = value!;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Addr',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: addrController,
                decoration: InputDecoration(
                  hintText: '주소를 입력하세요',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                readOnly: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                onPressed: () => _searchAddress(context),
                icon: const Icon(Icons.search, color: Colors.black),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
