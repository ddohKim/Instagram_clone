import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:test_1/models/firebase_auth_state.dart';
import 'package:test_1/repo/helper/image_helper.dart';

class ImageNetworkRepository{ //isolate로 사용하기(시간이 오래걸려서)
  Future<TaskSnapshot?> uploadImage(File originImage,{required String postKey})async {
    try {
      final File? resized = await compute(
          getResizedImage, originImage); //compute을 통해서 isolate 작업을 함
      final Reference reference = FirebaseStorage.instance.ref().child(_getImagePathByPostKey(postKey)); //postkey 값을 가져옴
      final UploadTask uploadTask = reference.putFile(resized!); //업로드
      return uploadTask;
    } catch (e) {
      print(e);
    }
  }
  String _getImagePathByPostKey(String postKey)=>'post/$postKey/post.jpg'; //post폴더에 postkey값에 post.jpg 생

  Future<dynamic> getPostImageUrl(String postKey){
    return FirebaseStorage.instance.ref().child(_getImagePathByPostKey(postKey)).getDownloadURL();
  }
}
ImageNetworkRepository imageNetworkRepository=ImageNetworkRepository();