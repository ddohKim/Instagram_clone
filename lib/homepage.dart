import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/screens/camera_screen.dart';
import 'package:test_1/screens/feed_screen.dart';
import 'package:test_1/screens/profile_screen.dart';
import 'package:test_1/screens/search_screen.dart';
import 'package:test_1/widgets/my_progress_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BottomNavigationBarItem> btmNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: "",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.add),
      label: "",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.healing),
      label: "",
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      label: "",
    ),
  ];

  int selectedIndex = 0;
  GlobalKey<ScaffoldState> _key =
      GlobalKey<ScaffoldState>(); //key를 사용해 scaffold를 카메라 접근허용에서 사용하기 위해

  static List<Widget> _screens = [
    Consumer<UserModelState>(
      builder: (BuildContext context, UserModelState userModelState, Widget? child) {
        if(userModelState==null||userModelState.userModel==null||userModelState.userModel!.followings==null||userModelState.userModel!.followings.isEmpty)
          return MyProgressIndicator(containerSize: size!.width,);
        else
        return FeedScreen(userModelState.userModel!.followings);
      },
    ),
    SearchScreen(),
    Container(color: Colors.greenAccent), //이 화면은 사용을 안한다고 생각하면 됨. 카메라로 이동
    Container(color: Colors.deepPurpleAccent),
    ProfileScreen(),
    

  ];

  void _onBtmItemClick(int A) {
    switch (A) {
      //카메라를 이용하기 위해서 2번을 눌렀을 때 멈추기
      case 2:
        _openCamera(); //navigator는 페이지 이동에 사용하는 클래스, push를 이용해 우리가 보여주고 싶은 페이지를 맨 위로 올려줌, case2는 카메라를 의미
        break;
      default:
        {
          setState(() {
            selectedIndex = A;
          });
        }
    }
  }

  void _openCamera() async {
    //checkifpermissiongranted를 통해 카메라 접근허용 체크
    if (await checkIfPermissionGranted(context))
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              CameraScreen())); //navigator는 페이지 이동에 사용하는 클래스, push를 이용해 우리가 보여주고 싶은 페이지를 맨 위로 올려줌,
    else {
      SnackBar snackBar = SnackBar(
          content: Text('카메라, 마이크 접근 허용을 해주세요'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              _key.currentState!.hideCurrentSnackBar();
              AppSettings.openAppSettings(); //ok를 누르면 appsetting 화면이 나옴
            },
          ));
      _key.currentState!
          .showSnackBar(snackBar); //scaffold에서 snackbar를 열지 않으면 에러가 난다.
    }
  }

  Future<bool> checkIfPermissionGranted(BuildContext context) async {
    //카메라를 열때 허락하는지 안하는지 체크, future강의는 나중에 다시 들어보기 여기 다시 공부할것!!
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Platform.isIOS ? Permission.photos : Permission.storage
    ].request();
    bool permitted = true;
    statuses.forEach((permission, permissionStatus) {
      if (!permissionStatus.isGranted) permitted = false;
    });
    return permitted;
  }

  @override
  Widget build(BuildContext context) {
    size ??= MediaQuery.of(context).size;
    return Scaffold(
      key: _key, //scaffold 카메라 허용에 이용하기 위해
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: btmNavItems,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.yellow,
        currentIndex: selectedIndex,
        onTap: _onBtmItemClick,
      ),
    );
  }
}
