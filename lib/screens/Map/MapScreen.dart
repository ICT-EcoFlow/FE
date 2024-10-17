import 'package:ecoflow/widgets/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart'; // JWT 토큰 관련 서비스 임포트
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedLocation;
  List<dynamic> _stats = [];
  final Location _location = Location();
  bool _isMyLocationEnabled = false;
  StreamSubscription<LocationData>? _locationSubscription;
  final Set<Marker> _userChargersMarkers = {};
  bool _isUserChargersEnabled = false;

  @override
  void initState() {
    super.initState();
    _location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {
        _startLocationUpdates();
      }
    });
  }

  void _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (_isMyLocationEnabled && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(locationData.latitude!, locationData.longitude!),
          ),
        );
      }
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel();
  }

  Future<void> _launchCaller(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunch(launchUri.toString())) {
        await launch(launchUri.toString());
      } else {
        print('전화를 걸 수 없습니다.');
      }
    } catch (e) {
      print('전화 걸기 오류: $e');
    }
  }

  Future<void> _fetchChargingStations({String? statNm}) async {
    final String? token = await getToken();
    if (token == null) {
      print('토큰이 유효하지 않습니다.');
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/infoByStatNm?statNm=${statNm ?? ''}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> locations = responseData['locations'];
      _stats = responseData['stats'];
      setState(() {
        _markers.clear();
        for (var location in locations) {
          _addChargingStationMarker(location);
        }
      });
      if (locations.isNotEmpty) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(locations[0]['lat'], locations[0]['lng']),
            14,
          ),
        );
      }
    } else {
      print('충전소 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _fetchUserChargers() async {
    final String? token = await getToken();
    if (token == null) {
      print('토큰이 유효하지 않습니다.');
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/usercherger/list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> userChargers = responseData;
      setState(() {
        _userChargersMarkers.clear();
        for (var charger in userChargers) {
          _addUserChargerMarker(charger);
        }
      });
    } else {
      print('개인 충전기 정보를 가져오는 중 오류가 발생했습니다.');
    }
  }

  Future<void> _addChargingStationMarker(Map<String, dynamic> location) async {
    try {
      BitmapDescriptor markerIcon;
      if (location['stat'] == '2') {
        markerIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(200, 200)),
            'assets/images/okok.png');
      } else {
        markerIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(200, 200)),
            'assets/images/nono.png');
      }

      double latitude = location['lat'] ?? 0.0;
      double longitude = location['lng'] ?? 0.0;

      if (latitude == 0.0 || longitude == 0.0) {
        print('잘못된 위치 데이터: ${location['lat']}, ${location['lng']}');
        return;
      }

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(location['statId'] ?? ''),
            position: LatLng(latitude, longitude),
            icon: markerIcon,
            onTap: () {
              setState(() {
                _selectedLocation = location;
              });
            },
          ),
        );
      });
      print('마커 추가 성공: ${location['statId']}');
    } catch (e) {
      print('마커 추가 중 오류 발생: $e');
    }
  }

  Future<void> _addUserChargerMarker(Map<String, dynamic> charger) async {
    try {
      BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(200, 200)),
        'assets/images/business.png',
      );

      double latitude = double.tryParse(charger['lat']) ?? 0.0;
      double longitude = double.tryParse(charger['lng']) ?? 0.0;

      if (latitude == 0.0 || longitude == 0.0) {
        print('잘못된 위치 데이터: ${charger['lat']}, ${charger['lng']}');
        return;
      }

      setState(() {
        _userChargersMarkers.add(
          Marker(
            markerId: MarkerId(charger['id'].toString()),
            position: LatLng(latitude, longitude),
            icon: markerIcon,
            onTap: () {
              setState(() {
                _selectedLocation = charger;
              });
            },
          ),
        );
      });
      print('개인 충전기 마커 추가 성공: ${charger['id']}');
    } catch (e) {
      print('개인 충전기 마커 추가 중 오류 발생: $e');
    }
  }

  void _toggleUserChargers() {
    setState(() {
      _isUserChargersEnabled = !_isUserChargersEnabled;
      if (_isUserChargersEnabled) {
        _fetchUserChargers();
      } else {
        _userChargersMarkers.clear();
      }
    });
  }

  String _getUsernameFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final payloadMap = json.decode(payload);
    return payloadMap['sub'];
  }

  Future<void> _callCheckStatAPI(int statId) async {
    final String? token = await getToken();
    if (token == null) {
      print('토큰이 유효하지 않습니다.');
      return;
    }

    final String username = _getUsernameFromToken(token);

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/auth/checkStat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "username": username,
        "id": statId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('충전기 예약 완료!')),
      );
      print('API 호출 성공: 개인 충전기 예약 완료');
    } else {
      print('API 호출 실패: ${response.statusCode}');
    }
  }

  Future<void> _callUserChargerPhoneAPI(int statId) async {
    final String? token = await getToken();
    if (token == null) {
      print('토큰이 유효하지 않습니다.');
      return;
    }

    final String username = _getUsernameFromToken(token);

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/auth/userchergerphone'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "username": username,
        "id": statId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('충전기 예약 완료!')),
      );
      print('API 호출 성공: 공용 충전기 예약 완료');
    } else {
      print('API 호출 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: '어디서 충전할까요?',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        await _fetchChargingStations(
                            statNm: _searchController.text);
                        if (_markers.isNotEmpty) {
                          final firstMarker = _markers.first;
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              firstMarker.position,
                              14,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Image.asset('assets/images/Mic_light.png'),
                      onPressed: () {
                        // 음성 입력 기능 추가 예정
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(37.5665, 126.9780),
                    zoom: 14,
                  ),
                  markers: _markers.union(_userChargersMarkers),
                  myLocationEnabled: _isMyLocationEnabled,
                  myLocationButtonEnabled: false,
                ),
              ),
            ],
          ),
          if (_selectedLocation != null) _buildOverlay(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "myLocation",
            onPressed: () {
              setState(() {
                _isMyLocationEnabled = !_isMyLocationEnabled;
                if (_isMyLocationEnabled) {
                  _startLocationUpdates();
                } else {
                  _stopLocationUpdates();
                }
              });
            },
            child: Icon(
              _isMyLocationEnabled
                  ? Icons.my_location
                  : Icons.location_disabled,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "userChargers",
            onPressed: _toggleUserChargers,
            child: Image.asset('assets/images/user.png'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: BottomBar(),
    );
  }

  Widget _buildOverlay() {
    final selectedStats = _stats
        .where((stat) => stat['statId'] == _selectedLocation!['statId'])
        .toList();

    return Positioned(
      top: 150,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 공통 정보 (충전소 이름 또는 개인 충전기 이름)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedLocation!['statNm'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedLocation = null;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Image.asset('assets/images/Location.png', width: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_selectedLocation!['addr'] ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 공통 정보 (전화번호)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final phoneNumber = _selectedLocation!['busiCall'];
                    if (phoneNumber != null && phoneNumber.isNotEmpty) {
                      _launchCaller(phoneNumber);
                    } else {
                      print('전화번호가 없습니다.');
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset('assets/images/Call.png', width: 20),
                      const SizedBox(width: 10),
                      Text(
                        _selectedLocation!['busiCall'] ?? '',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 공통 정보 (사용 시간)
            Row(
              children: [
                Image.asset('assets/images/time.png', width: 20),
                const SizedBox(width: 10),
                Text(_selectedLocation!['useTime'] ?? ''),
              ],
            ),
            const SizedBox(height: 10),
            // 공통 정보 (주차 정보)
            Row(
              children: [
                Image.asset('assets/images/parking.png', width: 20),
                const SizedBox(width: 10),
                Text(_selectedLocation!['parkingFree'] == 'Y' ? '무료' : '유료'),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            // 충전소 정보 (stats)
            if (selectedStats.isNotEmpty)
              ...selectedStats.map((stat) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '충전기 ID ${stat['chgerId']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('충전기 상태: '),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(stat['stat']),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    _getChargerStatus(stat['stat']),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (stat['stat'] == '3')
                              ElevatedButton(
                                onPressed: () async {
                                  await _callCheckStatAPI(stat['id']);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Image.asset('assets/images/booking.png',
                                    width: 50),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('충전기 타입: ${_getChargerType(stat['chgerType'])}'),
                      ],
                    ),
                  )),
            if (_selectedLocation!['id'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '개인 충전기 ID ${_selectedLocation!['id']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text('충전기 상태: '),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_selectedLocation!['stat']),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _getChargerStatus(_selectedLocation!['stat']),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '충전기 타입: ${_getChargerType(_selectedLocation!['chgerType'])}'),
                      if (_selectedLocation!['stat'] == '2')
                        ElevatedButton(
                          onPressed: () async {
                            await _callUserChargerPhoneAPI(
                                _selectedLocation!['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Image.asset('assets/images/booking.png',
                              width: 50),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getChargerStatus(String? stat) {
    switch (stat) {
      case '1':
        return '토신이상';
      case '2':
        return '충전대기';
      case '3':
        return '충전중';
      case '4':
        return '운영중지';
      case '5':
        return '점검중';
      case '9':
        return '상태미확인';
      default:
        return '알 수 없음';
    }
  }

  String _getChargerType(String? chgerType) {
    switch (chgerType) {
      case '01':
        return 'DC차데모';
      case '02':
        return 'AC완속';
      case '03':
        return 'DC차데모+AC3상';
      case '04':
        return 'DC콜보';
      case '05':
        return 'DC차데모+DC콜보';
      case '06':
        return 'DC차데모+AC3상+DC콜보';
      case '07':
        return 'AC3상';
      case '08':
        return 'DC콜보(완속)';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String? stat) {
    switch (stat) {
      case '2':
        return Colors.blue;
      case '3':
        return Colors.orange;
      case '5':
      case '9':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
