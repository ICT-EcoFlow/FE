import 'dart:async';
import 'package:flutter/material.dart';

class AutoScrollingAdBanner extends StatefulWidget {
  @override
  _AutoScrollingAdBannerState createState() => _AutoScrollingAdBannerState();
}

class _AutoScrollingAdBannerState extends State<AutoScrollingAdBanner> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
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
      height: 150,
      color: Color(0xFFD9D9D9), // 배경 색상
      child: PageView(
        controller: _pageController,
        children: <Widget>[
          _buildAdBanner('Ad 1', Colors.red),
          _buildAdBanner('Ad 2', Colors.green),
          _buildAdBanner('Ad 3', Colors.blue),
          _buildAdBanner('Ad 4', Colors.orange),
          _buildAdBanner('Ad 5', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildAdBanner(String adText, Color color) {
    return Container(
      alignment: Alignment.center,
      color: color,
      child: Text(
        adText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
