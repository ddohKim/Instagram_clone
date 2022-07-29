import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/camera_state.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/repo/helper/generate_post_key.dart';
import 'package:test_1/screens/share_post_screen.dart';
import 'package:test_1/widgets/my_progress_indicator.dart';

class TakePhoto extends StatefulWidget {
  const TakePhoto({
    Key? key,
  }) : super(key: key);

  @override
  State<TakePhoto> createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  Widget _progress = MyProgressIndicator(); //loading 화면

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraState>(//consumer를 이용해 camera_state의 정보들을 가져옴
        builder: (BuildContext context, CameraState cameraState, Widget) {
      return Column(
        children: [
          Container(
            width: size!.width,
            height: size!.width,
            color: Colors.black,
            child: (cameraState.isReadyToTakePhoto)
                ? _getPreview(cameraState)
                : _progress, //snapshot data가 null일수도 있기 때문에 이를 확인을 해줘야함(!를 이용)
          ),
          Expanded(
              child: OutlineButton(
            onPressed: () {
              if (cameraState.isReadyToTakePhoto) {
                _attemptTakePhoto(cameraState, context);
              }
            },
            shape: CircleBorder(),
            borderSide: BorderSide(color: Colors.black12, width: 20),
          ))
        ],
      );
    });
  }

  Widget _getPreview(CameraState camerastate) {
    return ClipRect(
      //cliprect 는 overflowbox 된 것중 안보이는 부분을 자름
      child: OverflowBox(
          //위의 카메라 검은박스 비율이 1대 1인데 여기에 벗어나 카메라 비율을 맞추기 위해서
          alignment: Alignment.center,
          child: FittedBox(
              //가로길이가 맞게 카메라 비율 맞추기
              fit: BoxFit.fitWidth,
              child: Container(
                  width: size!.width,
                  height:
                      size!.width / camerastate.controller.value.aspectRatio,
                  // aspectratio 는 가로세로비율 ,카메라 비율대로 맞춰준것
                  child: CameraPreview(camerastate.controller)))),
    );
  }

  void _attemptTakePhoto(CameraState cameraState,BuildContext context) async {
    final String postKey=getNewPostKey(Provider.of<UserModelState>(context,listen: false).userModel!);
    try {
      //final path = join((await getTemporaryDirectory()).path, '$postKey.png'); // 저장 위치는 gettemporary...
      XFile picture=await cameraState.controller.takePicture(); //takepicture에  path 저장해라
      File imageFile=File(picture.path);
      Navigator.of(context).push(MaterialPageRoute(builder:(_)=> SharePostScreen(imageFile,postKey: postKey,)));
    } catch (e) {}
  }
}

//InkWell( //카메라 클릭버튼을 만들어줄때 이렇게도 만들어 줄수 있음. inkwell의 ontap을 이용해서 버튼이 아닌것을 버튼으로 만듬 하지만 버튼만 클릭되는게 아니라 해당 영역 전체가 클릭 가능하게 되서 이용은 안함
//onTap: (){},
//child: Padding(
//padding: const EdgeInsets.all(common_xxs_gap),
//child: Container(
//decoration: ShapeDecoration( //원형을 만들어주기 위해
//shape: CircleBorder(side: BorderSide(color: Colors.black12,width: 20))),),),)
