import 'package:flutter/material.dart';
import 'package:ecoflow/screens/home/homepage.dart';

//void main() => runApp(MyApp());

class loginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: LogIn(),
    );
    throw UnimplementedError();
  }
}

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          //배경 이미지
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/Background.png',
              fit: BoxFit.cover, //이미지 원본 크기 그대로 유지
              alignment: Alignment.bottomCenter, //아랫부분을 기준으로 정렬
            ),
            //email. pw 입력하는 부분을 제외한 화면을 탭하면, 키보드 사라지게 GestureDetector
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //특정 영역에만 여백을 지정
                    Padding(
                      padding: EdgeInsets.only(top: 110),
                      child: Center(
                        child: Text(
                          '나를 위한\n나의 전기차를 위한',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Form(
                      child: Theme(
                          data: ThemeData(
                              primaryColor: Colors.grey,
                              inputDecorationTheme: InputDecorationTheme(
                                  labelStyle: TextStyle(
                                      color: Colors.teal, fontSize: 15.0))),
                          child: Container(
                            padding: EdgeInsets.all(40.0),
                            //키보드가 올라와서 만약 스크린 영역을 차지하는 경우 스크롤 되도록
                            //SingleChildScrollView로 감싸줌
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                        labelText: '이메일을 입력해주세요.'),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  TextField(
                                    controller: controller2,
                                    decoration: InputDecoration(
                                        labelText: '비밀전호를 입력하세요.'),
                                    keyboardType: TextInputType.text,
                                    //비밀번호는 안 보이도록 하기
                                    obscureText: true,
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                  ),
                                  ButtonTheme(
                                    minWidth: 100.0,
                                    height: 50.0,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (controller.text ==
                                                'admin@hello.com' &&
                                            controller2.text == '1234') {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          Homepage()));
                                        } else if (controller.text ==
                                                'admin@hello.com' &&
                                            controller2 != '1234') {
                                          showSnackBar(
                                              context, Text('잘못된 비밀번호입니다.'));
                                        } else if (controller.text !=
                                                'admin@hello.com' &&
                                            controller2 == '1234') {
                                          showSnackBar(
                                              context, Text('잘못된 이메일입니다.'));
                                        } else {
                                          showSnackBar(
                                              context, Text('정보를 확인하세요.'));
                                        }
                                      },
                                      child: const Text('로그인'),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(225, 112, 48, 48),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
