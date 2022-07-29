import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/models/camera_state.dart';
import 'package:test_1/models/gallery_state.dart';
import 'package:test_1/widgets/my_gallery.dart';
import 'package:test_1/widgets/take_photo.dart';

class CameraScreen extends StatefulWidget {
  CameraState _cameraState = CameraState();
  GalleryState _galleryState=GalleryState();

  @override
  _CameraScreenState createState() {
    _cameraState
        .getReadyToTakePhoto(); //camerastate에서 getreadytotakephoto를 통해 미리 사진찍을 준비를 함
    _galleryState.initProvider(); //gallery 초기화 미리 준비
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen> {
  int _currentIndex = 1; //무엇을 선택했는지 알기위해서 번호부여, 첫페이지를 photo로 보이고 싶음
  PageController _pageController =
      PageController(initialPage: 1); // 첫페이지를 photo로 보이고 싶음
  String _title = 'Photo';

  @override
  void dispose() {
    //controller에서는 해줘야함 memory leak이 발생하지 않기 위해
    _pageController.dispose();
    widget._cameraState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CameraState>.value(value: widget._cameraState), //notifierprovider를 통해서 그 값들을 여기서도 가져옴?( 다시 공부하자)
        ChangeNotifierProvider<GalleryState>.value(value: widget._galleryState),
      ],
      child: Scaffold(
        appBar: AppBar(
          //자동으로 백버튼이 생성되는데 이유는 homepage.dart의 _opencamera에서 stack으로 쌓였기 때문에 그 전에 어떤 페이지가 있는지 알아서 알고 있기 때문
          title: Text(_title),
        ),
        body: PageView(
          controller: _pageController, //controller 를 이용해 페이지를 넘겨다닐수 있도록
          children: [
            MyGallery(),
            TakePhoto(),
            Container(
              color: Colors.greenAccent,
            ),
          ],
          onPageChanged: (index) {
            //페이지가 바뀔때 _currentIndex도 바꿔줘서 아래 bottomnavigationbar 버튼도 같이 바뀔수 있게 해줌
            setState(() {
              _currentIndex = index;
              switch (_currentIndex) {
                case 0:
                  _title = 'Gallery';
                  break;
                case 1:
                  _title = 'Photo';
                  break;
                case 2:
                  _title = 'Video';
                  break;
              }
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 0,
          //아이콘을 안보이게 하려고
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.radio_button_checked), title: Text('GALLERY')),
            BottomNavigationBarItem(
                icon: Icon(Icons.radio_button_checked), title: Text('PHOTO')),
            BottomNavigationBarItem(
                icon: Icon(Icons.radio_button_checked), title: Text('VIDEO')),
          ],
          currentIndex: _currentIndex,
          //_currentIndex를 선택할때마다 계속 바꿔줌
          onTap: _onItemTabbed,
        ),
      ),
    );
  }

  void _onItemTabbed(index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(_currentIndex,
          duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
    });
  }
}
