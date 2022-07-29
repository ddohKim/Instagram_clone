import 'dart:io';

import 'package:image/image.dart';
//시간이 오래걸리기 때문에 main에서 하는게 아닌 isolate에서 작업을 함(끊김현상이 없도록)
File ?getResizedImage(File originImage){
  Image? image=decodeImage(originImage.readAsBytesSync()); //byte로 사진을 읽어옴
  Image resizedImage=copyResizeCropSquare(image!, 300); //사진을 정사각형으로, 가로 세로는 300으로

  File resizedFile=File(originImage.path.substring(0,originImage.path.length-3)+"jpg"); //.png만 빼고 다 가져옴
 resizedFile.writeAsBytesSync(encodeJpg(resizedImage,quality:50)); //퀄리티도 50퍼센트 떨어트린상태로
 return resizedFile;
}