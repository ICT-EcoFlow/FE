import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecoflow/services/token_storage.dart'; // JWT 토큰 관련 서비스 임포트
import 'package:ecoflow/screens/home/aiBot.dart';
import 'package:ecoflow/screens/home/homepage.dart';
import 'package:get/get.dart';
import 'dart:async'; // 이 부분 추가

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
  bool _isMyLocationEnabled = false; // 내 위치 보기 상태를 저장할 변수 추가
  StreamSubscription<LocationData>? _locationSubscription; // 위치 데이터 스트림 관리
  final Set<Marker> _userChargersMarkers = {}; // 개인 충전기 마커
  bool _isUserChargersEnabled = false; // 개인 충전기 마커 활성화 여부
  double? _currentLat; // 현재 위치의 위도
  double? _currentLng; // 현재 위치의 경도

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
      _currentLat = locationData.latitude;
      _currentLng = locationData.longitude;

      if (_isMyLocationEnabled && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(_currentLat!, _currentLng!),
          ),
        );
      }
    });
  }

  void _stopLocationUpdates() {
    _locationSubscription?.cancel(); // 위치 스트림 구독 취소
  }

  // 충전소 정보를 가져오는 함수
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

  // 개인 충전기 정보를 가져오는 함수
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

  // 충전소 마커 추가
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

  // 개인 충전기 마커 추가
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

  // 개인 충전기 마커 활성화/비활성화하는 함수
  void _toggleUserChargers() {
    setState(() {
      _isUserChargersEnabled = !_isUserChargersEnabled;
      if (_isUserChargersEnabled) {
        _fetchUserChargers(); // 개인 충전기 정보를 가져와서 마커를 추가
      } else {
        _userChargersMarkers.clear(); // 개인 충전기 마커 비활성화
      }
    });
  }

  // API로 현재 위치 전송 및 응답 콘솔 출력
  Future<void> _sendCurrentLocation() async {
    if (_currentLat == null || _currentLng == null) {
      print('현재 위치를 찾을 수 없습니다.');
      return;
    }

    final String? token = await getToken();
    if (token == null) {
      print('토큰이 유효하지 않습니다.');
      return;
    }

    final response = await http.post(
      Uri.parse(
          'http://localhost:8080/api/AiMap2?lat=$_currentLat&lng=$_currentLng'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('서버 응답: ${response.body}');
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
                    target: LatLng(37.5665, 126.9780), // 서울시청 기준 좌표
                    zoom: 14,
                  ),
                  markers: _markers.union(_userChargersMarkers),
                  myLocationEnabled: _isMyLocationEnabled,
                  myLocationButtonEnabled: false,
                ),
              ),
            ],
          ),
          Positioned(
            top: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: "sendCurrentLocation",
              onPressed: _sendCurrentLocation,
              child: Image.asset('assets/icons/aiIcon.png'),
            ),
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
            Row(
              children: [
                Image.asset('assets/images/Call.png', width: 20),
                const SizedBox(width: 10),
                Text(_selectedLocation!['busiCall'] ?? ''),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset('assets/images/time.png', width: 20),
                const SizedBox(width: 10),
                Text(_selectedLocation!['useTime'] ?? ''),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset('assets/images/parking.png', width: 20),
                const SizedBox(width: 10),
                Text(_selectedLocation!['parkingFree'] == 'Y' ? '무료' : '유료'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Image.asset('assets/icons/carIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      // 다른 화면으로 이동하는 코드 추가 가능
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/icons/cardIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      // 다른 화면으로 이동하는 코드 추가 가능
                    },
                  ),
                  const SizedBox(width: 63),
                  IconButton(
                    icon: Image.asset('assets/icons/mapIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      Get.to(
                        MapScreen(),
                        transition: Transition.noTransition,
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/icons/aiIcon.png'),
                    iconSize: 45,
                    onPressed: () {
                      Get.to(
                        const Aibot(),
                        transition: Transition.noTransition,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF446DBE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 0),
                    blurRadius: 7,
                  ),
                ],
              ),
              child: IconButton(
                icon: Image.asset('assets/icons/elec.png'),
                iconSize: 45,
                onPressed: () {
                  Get.to(
                    Homepage(),
                    transition: Transition.noTransition,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
