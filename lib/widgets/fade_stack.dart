import 'package:flutter/material.dart';
import 'package:test_1/screens/auth_screen.dart';
import 'package:test_1/widgets/sign_in_form.dart';
import 'package:test_1/widgets/sign_up_form.dart';

class FadeStack extends StatefulWidget {
  final int selectedForm;

  const FadeStack({Key? key, required this.selectedForm}) : super(key: key);

  @override
  _FadeStackState createState() => _FadeStackState();
}

class _FadeStackState extends State<FadeStack>
    with SingleTickerProviderStateMixin {
  //singleticker..은 한가지 애니메이션 효과를 사용할때 이용(fadetransition){
  late AnimationController _animationController;

  List<Widget> forms = //signup, signin 페이지를 계속 리셋시키지 않고 기록이 저장되어있기 위해
      [SignInForm(),
    SignUpForm(),

  ];

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,//singleticker를 던지려고 this 사용
        duration: Duration(milliseconds: 300));
    _animationController.forward();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FadeStack oldWidget) {
    //oldwidget, nowwidget의 다른점을 비교
    if (widget.selectedForm != oldWidget.selectedForm) {
      _animationController.forward(from: 0.0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      //fadetransition 은 헷갈림 다시 볼것!
      opacity: _animationController,
      child: IndexedStack(
        index: widget.selectedForm, //다른 곳의 function? 쓰려면 widget을 씀
        children: forms,
      ),
    );
  }
}
