import 'package:flutter/material.dart';

//void main() => runApp(MyApp());

class loginScreen extends StatelessWidget{
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LogIn'),
        elevation: 0.0,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          //특정 영역에만 여백을 지정
          Padding(padding: EdgeInsets.only(top: 50)),
          Form(
            child: Theme(
              data: ThemeData(
                primaryColor: Colors.grey,
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.teal, fontSize: 15.0)
                )
              ),
              child: Container(
                padding: EdgeInsets.all(40.0),
                //키보드가 올라와서 만약 스크린 영역을 차지하는 경우 스크롤 되도록
                //SingleChildScrollView로 감싸줌
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: '이메일을 입력해주세요.'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: '비밀전호를 입력하세요.'),
                        keyboardType: TextInputType.text,
                        //비밀번호는 안 보이도록 하기
                        obscureText: true,
                      ),
                      SizedBox(height: 40.0,),
                      ButtonTheme(
                        minWidth: 100.0,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: (){
  
                          },
                          child: const Text('로그인'),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),
          )
        ],
      ),
    );
  }
}