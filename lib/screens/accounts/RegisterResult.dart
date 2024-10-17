import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecoflow/screens/accounts/loginScreen.dart';

class RegisterResult extends StatelessWidget {
  const RegisterResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Background.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ecoflow_logo.png',
                width: 600,
                height: 200,
              ),
              const SizedBox(height: 120),
              const Text(
                '회원가입이 완료되었습니다.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '로그인 후 안전하고 편리하게\nECO FLOW 서비스를 이용하실 수 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 150),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => LogIn(), transition: Transition.rightToLeft);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                child: Text('로그인'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
