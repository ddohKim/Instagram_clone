import 'package:flutter/material.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/firestore/post_model.dart';
import 'package:test_1/widgets/profile_body.dart';
import 'package:test_1/widgets/profile_side_menu.dart';

class ProfileScreen extends StatefulWidget {
   ProfileScreen( {Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final duration = Duration(milliseconds: 300);
  final menuWidth = size!.width / 2;

  Menustatus _menustatus = Menustatus.closed;
  double bodyXPos = 0;
  double menuXPos = size!.width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          //프로필화면과 메뉴가 animationcontainer 를 이용하여 왔다갔다 하기 위해 stack 사용
          children: [
            AnimatedContainer(
              duration: duration,
              curve: Curves.fastOutSlowIn,
              child: ProfileBody(onMenuChanged: () {//oMenuChanged를 이용해 profilebody의 appbar 속 아이콘을 클릭하면 이 함수가실행
                setState(() {
                  _menustatus = (_menustatus == Menustatus.closed)
                      ? Menustatus.opened
                      : Menustatus.closed;
                  switch (_menustatus) {
                    case Menustatus.opened:
                      bodyXPos = -menuWidth;
                      menuXPos = size!.width - menuWidth;
                      break;
                    case Menustatus.closed:
                      bodyXPos = 0;
                      menuXPos = size!.width;
                      break;
                  }
                });
              }),
              transform: Matrix4.translationValues(bodyXPos, 0, 0),
            ),
            AnimatedContainer(
              duration: duration,
              curve: Curves.fastOutSlowIn,
              transform: Matrix4.translationValues(menuXPos, 0, 0),
              child: Positioned(
                  top: 0,
                  bottom: 0,
                  width: menuWidth,
                  child: Container(color: Colors.grey[200],child: ProfileSideMenu(menuWidth))),
            ),
            //positioned 는 stack 안에서 모양을 결정하는데 이용, positioned 위젯은 항상 stack children 안에 들어와야함=>전엔 그랬는데 지금은 오류 안나는걸보니 상관없는걸루... positioned 없어도 실행은 잘됨
          ],
        ));
  }
}

enum Menustatus { opened, closed }
