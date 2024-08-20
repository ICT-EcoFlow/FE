import 'package:ecoflow/widgets/carwash.dart';
import 'package:flutter/material.dart';

DraggableScrollableSheet buildCustomBottomSheet() {
  return DraggableScrollableSheet(
    initialChildSize: 0.7, // 초기 크기를 부모의 60%로 설정
    minChildSize: 0.6, // 최소 크기
    maxChildSize: 1.0, // 최대 크기
    builder: (BuildContext context, ScrollController scrollController) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth, // 부모의 너비에 맞추기
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.7),
                  offset: Offset(0, 0),
                  blurRadius: 7,
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(height: 40,),
                Carwash(),
              ],
            )
          );
        },
      );
    },
  );
}
