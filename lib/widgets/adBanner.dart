import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollingAdBanner extends StatefulWidget {
  const AutoScrollingAdBanner({super.key});

  @override
  _AutoScrollingAdBannerState createState() => _AutoScrollingAdBannerState();
}

class _AutoScrollingAdBannerState extends State<AutoScrollingAdBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 1) {
        // 2개의 이미지만 사용
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: 150, // 높이 설정
      color: const Color(0xFFD9D9D9), // 배경 색상
      child: PageView(
        controller: _pageController,
        children: <Widget>[
          _buildAdBanner('assets/images/ad/003.png'), // 이미지 1
          _buildAdBanner('assets/images/ad/004.png'), // 이미지 2
        ],
      ),
    );
  }

  Widget _buildAdBanner(String imagePath) {
    return Container(
      alignment: Alignment.center,
      child: ClipRRect(
        // 이미지의 모서리를 둥글게 하기 위한 ClipRRect 사용 (선택 사항)
        borderRadius: BorderRadius.circular(0), // 모서리 둥글게 설정
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover, // 가로 세로 비율에 맞게 조정
          width: double.infinity, // 가로폭을 최대화
          height: 200, // 고정된 높이
        ),
      ),
    );
  }
}
