import 'package:flutter/cupertino.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';

class GalleryState extends ChangeNotifier{
  late LocalImageProvider _localImageProvider;
  late bool _hasPermission;
  late List<LocalImage> _images;

  Future<bool> initProvider() async{
    _localImageProvider=LocalImageProvider();
    _hasPermission=await _localImageProvider.initialize(); //future값이기 때문에 await 써줌, haspermission 초기화 해줌
  if(_hasPermission){
    _images=await _localImageProvider.findLatest(30);//최근30개의 사진을 가져옴
    notifyListeners();//_image에 사진을 업로드했음을 알림
    return true;
  }
  else {
    return false;
  }
  }

  List<LocalImage> get images=>_images; //외부에서도 이 값들을 사용하기 위해
  LocalImageProvider get localImageProvider=>_localImageProvider;
}