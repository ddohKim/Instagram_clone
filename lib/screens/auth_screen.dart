import 'package:flutter/material.dart';
import 'package:test_1/widgets/fade_stack.dart';
import 'package:test_1/widgets/sign_in_form.dart';
import 'package:test_1/widgets/sign_up_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  //sign in, sign up 페이지를 계속 교차시켜주는 코딩

  int selectedForm = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, //키보드가 올라와도 아래 글씨가 같이 안따라오도록해
        body: SafeArea(
          child: Stack(
            children: [
              FadeStack(selectedForm: selectedForm),
              Positioned(
                //stack 안에서만 positioned 쓸 수 있음
                left: 0,
                right: 0,
                bottom: 0,
                height: 40,
                child: Container(
                    color: Colors.white,
                    child: FlatButton(
                        shape: Border(top: BorderSide(color: Colors.grey)),
                        //윗 테두리를 줄을 만들기 위해서
                        onPressed: () {
                          setState(() {
                            if (selectedForm == 0) {
                              // is 를 이용해 A가 B를 통해 만든건지 확인(여기서는 안씀)
                              selectedForm = 1;
                            } else {
                              selectedForm = 0;
                            }
                          });
                        },
                        child: RichText(
                            //richtext> text> textspan widget 속에 2개의 텍스트를 사용하기 위해 switch 됨
                            text: TextSpan(
                                text: (selectedForm == 0)
                                    ? "Don't have an account? "
                                    : 'Already have an account? ',
                                style: TextStyle(color: Colors.red),
                                children: [
                              TextSpan(
                                  text: (selectedForm == 0)
                                      ? "Sign Up"
                                      : "Sign In",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold)),
                            ])))),
              ), //flatbutton을 이용해 글자버튼을 만듬
            ],
          ),
        ));
  }
}
