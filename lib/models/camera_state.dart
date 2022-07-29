import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

//순서
//available camera 가져오기
//카메라 리스트에서 첫번째 카메라 사용
//CameraController 인스턴스 생성
//CameraController initialize()
// show preview
// set ready to take photo

class CameraState extends ChangeNotifier {
  late CameraController _controller; //여기 데이터는 외부에서 못건드리게 함
  late CameraDescription _cameraDescription;
  bool _readyTakePhoto = false;

  @override
  void dispose() {
      _controller.dispose();
    _readyTakePhoto = false;
    notifyListeners(); //다른 곳에 dispose 됐음을 알려줌
    super.dispose();
  }

  void getReadyToTakePhoto() async {
    List<CameraDescription> cameras =
        await availableCameras(); //cameras 가 future이기 때문에 await을 통해 기다려야함, availablecameras를 통해 해당유저의 카메라 상태 및 이용가능한지 가져옴

    if (cameras != null && cameras.isNotEmpty) {
      setCameraDescription(cameras[0]);
    }

    bool init = false;
    while (!init) {
      init = await initialize();
    }
  }

  Future<bool> initialize() async {
    try {
      //init이 false인 상태에서 initialize가 성공할때까지 while문을 통해서 계속 initialize를 해주는 것, 중간에 실패가 되면 catch를 통해 false를 보내줌
      await _controller.initialize();
      return true;
    } catch (e) {
      return false;
    }
  }

  void setCameraDescription(CameraDescription cameraDescription) {
    _cameraDescription = cameraDescription;
    _controller = CameraController(_cameraDescription, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.yuv420);
  }

  CameraController get controller =>
      _controller; //외부에서 데이터를 가져다가 쓸 수 있기 위해 이렇게 해둠 이때 원본 데이터는 건드리지 않기 위해서 따로 get 해줌
  CameraDescription get description => _cameraDescription;

  bool get isReadyToTakePhoto => _readyTakePhoto;
}
