import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecoflow/screens/home/homepage.dart';
void main() {
  runApp(const EcoFlow());
}

class EcoFlow extends StatelessWidget {
  const EcoFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}