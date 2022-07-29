import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:local_image_provider/device_image.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:test_1/models/gallery_state.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/repo/helper/generate_post_key.dart';
import 'package:test_1/screens/share_post_screen.dart';

class MyGallery extends StatefulWidget {
  const MyGallery({Key? key}) : super(key: key);

  @override
  _MyGalleryState createState() => _MyGalleryState();
}

class _MyGalleryState extends State<MyGallery> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryState>(builder:
        (BuildContext context, GalleryState galleryState, Widget? child) {
      return GridView.count(
        crossAxisCount: 3, //crossAxiscount 가로에 3개
        children: getImages(context, galleryState),
      );
    });
  }

  List<Widget> getImages(BuildContext context, GalleryState galleryState) {
    return galleryState.images
        .map((localImage) => InkWell(
                onTap: ()async{
                  Uint8List bytes=await localImage.getScaledImageBytes(galleryState.localImageProvider, 0.3);//local 이미지를 byte로 바꿈(나중에 또 file로 바꿈)

                  final String postKey=getNewPostKey(Provider.of<UserModelState>(context,listen: false).userModel!);
                  try {
                    final path = join((await getTemporaryDirectory()).path, '$postKey.png'); //파일명 timeinmilli, 저장 위치는 gettemporary...
                    File imageFile=File(path)..writeAsBytesSync(bytes); //해당 byte를 File에 넣고 imagefile에 저장
                    Navigator.of(context).push(MaterialPageRoute(builder:(_)=> SharePostScreen(imageFile,postKey: postKey,)));
                  } catch (e) {}

                },
                child: Image(
              image: DeviceImage(localImage,scale: 0.1), //scale로 메모리를 줄이기 (사이즈)
                  fit: BoxFit.cover, //크기가 정사각형으로 보이게, 사진이 짤릴수도 있음
            )))
        .toList(); //localImage를 가져오고 tolist를 통해 리스트로 다시 변환해
  }

}
