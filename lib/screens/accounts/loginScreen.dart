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
  //비밀번호 보이기 기능
  bool isPasswordVisible = false;
  //글자가 입력되면 버튼 투명도 50% -> 100% 하기 위해서
  //아이디, 비번이 입력되지 않았는데 버튼이 클릭되면 안 됨
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_validateInputs);
    controller2.addListener(_validateInputs);
  }

  void _validateInputs() {
    setState(() {
      isButtonEnabled = controller.text.isNotEmpty && controller2.text.isNotEmpty;
    });
  }

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
                      padding: EdgeInsets.only(top: 160),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        '아이디',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        )
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Center(
                                    child: Container(
                                      width: 316,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      child: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          hintText: '이메일을 입력해주세요.',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF555555).withOpacity(0.7), // 여기서 설정
                                          ),
                                          border: InputBorder.none,
                                          //TextField 내부에 입력된 텍스트와 필드 가장자리 사이 패딩 설정
                                          //왼,오에 각각 16.0씩 패딩
                                          //글자가 너무 가장자리에 글자가 붙지 않도록 - 가독성 높이기 위해 사용
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        '비밀번호',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        )
                                    ),
                                  ),

                                  SizedBox(height: 4),
                                  Center(
                                    child: Container(
                                      width: 316,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      child: TextField(
                                        controller: controller2,
                                        decoration: InputDecoration(
                                          hintText: '비밀번호를 입력해주세요.',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF555555).withOpacity(0.7),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isPasswordVisible = !isPasswordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                        // keyboardType: TextInputType.text,
                                        // 비밀번호는 안 보이도록 하기
                                        // 복사 불가
                                        obscureText: !isPasswordVisible,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 25.0),
                                  Center(
                                      child: Container(
                                        width: 316,
                                        height: 47,
                                        child: ElevatedButton(
                                          onPressed: isButtonEnabled ? () {
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
                                          }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white.withOpacity(isButtonEnabled ? 1.0 : 0.6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(40.0),
                                            ),
                                          ),
                                          child: const Text('로그인 하기',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                          ),
                                        ),
                                      ),

                                  )

                                ],
                              ),
                            ),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(225, 112, 48, 48),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
