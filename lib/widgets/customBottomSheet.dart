import 'package:ecoflow/widgets/adBanner.dart';
import 'package:ecoflow/widgets/carwash.dart';
import 'package:ecoflow/widgets/howtocharge.dart';
import 'package:ecoflow/widgets/news.dart';
import 'package:ecoflow/widgets/weather.dart';
import 'package:flutter/material.dart';

DraggableScrollableSheet buildCustomBottomSheet() {
  return DraggableScrollableSheet(
    initialChildSize: 0.7, // 초기 크기를 부모의 70%로 설정
    minChildSize: 0.2, // 최소 크기
    maxChildSize: 1.0, // 최대 크기
    builder: (BuildContext context, ScrollController scrollController) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.7),
              offset: const Offset(0, 0),
              blurRadius: 7,
            ),
          ],
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Container(
                width: 70,
                height: 2,
                color: const Color(0xFFABABAB),
              ),
              const SizedBox(height: 40),
              Carwash(),
              const SizedBox(height: 40),
              const Weather(),
              const SizedBox(height: 40),
              AutoScrollingAdBanner(),
              const SizedBox(
                height: 40,
              ),
              const News(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    },
  );
}
