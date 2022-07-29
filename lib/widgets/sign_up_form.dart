import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/auth_import_decor.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/homepage.dart';
import 'package:test_1/models/firebase_auth_state.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); //form 속의 상태를 저장하고 확인하기 위해 (로그인할때)

  TextEditingController _emailController =
      TextEditingController(); //textformfield 를 사용하기 위해서는 이게 필요
  TextEditingController _pwController = TextEditingController();
  TextEditingController _cpwController = TextEditingController();

  @override
  void dispose() {
    //controller는 최대한 dispose 해줘야 메모리 leak이 발생안함
    _emailController.dispose();
    _pwController.dispose();
    _cpwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, //키보드에 따라 같이 올라오도
      body: Padding(
        padding: const EdgeInsets.all(common_gap),
        child: Form(
          key: _formKey,
          child: ListView(
            //휴대폰의 사이즈가 다르기 때문에 scroll을 필요할수도 있기 때문에 column을 쓰지 않음
            children: [
              const SizedBox(
                height: common_l_gap,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 30),
                child: Center(
                    child: Text('SomSaTang',
                        style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'VeganStyle',
                            color: Colors.black87))),
              ),
              TextFormField(
                cursorColor: Colors.black54,
                controller: _emailController,
                decoration: textinputDecor('Email'),
                validator: (text) {
                  //해당 이메일의 주소가 맞는지 확인하는 작업
                  if (text!.isNotEmpty &&
                      text.contains("@") &&
                      text.contains(".")) {
                    return null;
                  } else {
                    return '정확한 이메일 주소를 입력해주세요';
                  }
                },
              ),
              const SizedBox(
                height: common_xxs_gap,
              ),
              TextFormField(
                cursorColor: Colors.black54,
                obscureText: true,
                //password *로 보이게 하기
                controller: _pwController,
                decoration: textinputDecor('Password'),
                validator: (text) {
                  //해당 패스워드가 맞는지 확인하는 작업
                  if (text!.isNotEmpty && text.length > 5) {
                    return null;
                  } else {
                    return '비밀번호는 최소 6자리 이상입니다';
                  }
                },
              ),
              const SizedBox(
                height: common_xxs_gap,
              ),
              TextFormField(
                cursorColor: Colors.black54,
                obscureText: true,
                //password *로 보이게 하기
                controller: _cpwController,
                decoration: textinputDecor('Confirm Password'),
                validator: (text) {
                  //해당 패스워드가 위랑 같은지 확인하는 작업
                  if (text!.isNotEmpty &&
                      _pwController.text == _cpwController.text) {
                    return null;
                  } else {
                    return '입력한 값이 비밀번호와 다릅니다';
                  }
                },
              ),
              _joinbutton(context),
              const SizedBox(
                height: common_xxs_gap,
              ),
              ordivider(),
              FlatButton.icon(  //facebook 이동 아이콘을 만드는데 아이콘과 text 동시에 사용되는 것
                  onPressed: () {Provider.of<FirebaseAuthState>(context,listen: false).loginWithFacebook(context); },
                  textColor: Colors.blue, //이름은 textcolor 이나 icon 색깔도 같이 바뀜
                  icon: ImageIcon(AssetImage('assets/images/facebook.png')),
                  label: Text('Login with Facebook'))
            ],
          ),
        ),
      ),
    );
  }

  FlatButton _joinbutton(BuildContext context) {
    return FlatButton(
              color: Colors.greenAccent,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  //join 버튼을 눌렀을 때 formkey에 담긴 값들을 validator를 통해 확인
                  print('Validation success');
                  Provider.of<FirebaseAuthState>(context,listen: false).registerUser(context,email: _emailController.text, password: _pwController.text);
                }
              },
              child: Text(
                'Join',
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(common_xxs_gap)),
            );
  }


}

Stack ordivider() {
  return Stack(
    //stack을 이용해 밑줄과 OR를 겹치게 만들었음
    alignment: Alignment.center,
    children: [
      Positioned(
        left: 0,
        right: 0,
        height: 1,
        child: Container(
          color: Colors.grey[300],
        ),
      ),
      Container(
        color: Colors.grey[50],
        height: 3,
        width: 60,
      ),
      Text('OR',
          style:
          TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold))
    ],
  );
}


