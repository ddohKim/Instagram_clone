import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/material_white.dart';
import 'package:test_1/homepage.dart';
import 'package:test_1/models/firebase_auth_state.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/repo/user_network_repository.dart';
import 'package:test_1/screens/auth_screen.dart';
import 'package:test_1/widgets/my_progress_indicator.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //위와 같은 것을 하지 않으면 firebase 실행도중 ios에서 오류발생
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  FirebaseAuthState _firebaseAuthState = FirebaseAuthState();
  Widget? _currentWidget;

  @override
  Widget build(BuildContext context) {
    _firebaseAuthState.watchAuthChange();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseAuthState>.value(
            value: _firebaseAuthState),
        ChangeNotifierProvider<UserModelState>(
          create: (_) => UserModelState(),
        ), //이해 잘 안됨
      ],
      child: MaterialApp(
        home: Consumer<FirebaseAuthState>(builder: (BuildContext context,
            FirebaseAuthState firebaseAuthState, Widget? child) {
          switch (firebaseAuthState.firebaseAuthStatus) {
            case FirebaseAuthStatus.signout:
              _clearUserModel(context);
              _currentWidget = AuthScreen();
              break;
            case FirebaseAuthStatus.signin:
              _initUserModel(firebaseAuthState, context);
              _currentWidget = HomePage();
              break;
            default:
              _currentWidget = MyProgressIndicator();
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 1000),
            //signin, signout fadeout 효과를 주는것
            switchInCurve: (Curves.fastOutSlowIn),
            child: _currentWidget,
          );
        }),
        theme: ThemeData(primarySwatch: white),
      ),
    );
  }

  void _initUserModel(
      FirebaseAuthState firebaseAuthState, BuildContext context) {
    UserModelState userModelState =
        Provider.of<UserModelState>(context, listen: false);
    userModelState.currentStreamSub = userNetworkRepository
        .getUserModelStream(firebaseAuthState.firebaseUser!.uid)
        .listen((userModel) {
      userModelState.userModel =
          userModel; //notifylistener가 있으면 listen false를 던져줌, 안하면 오류남, 처음 로그인하면 계속 subcription 업데이트를 해줌
    });
  }

  void _clearUserModel(BuildContext context) {
    UserModelState userModelState = Provider.of<UserModelState>(context,
        listen: false); //로그아웃시 subscription 삭제
    userModelState.clear();
  }
}
