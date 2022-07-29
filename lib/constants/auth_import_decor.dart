import 'package:flutter/material.dart';

import 'common_size.dart';

InputDecoration textinputDecor(String hint) { //이름에 _ 가 없어야 다른 파일에서도 쓸수 있음
  return InputDecoration(
    //글자를 쓸수 있게 만듬, enable을 통해 테두리 생성
      hintText: hint,
      enabledBorder: activeInputBorder(),
      errorBorder: errorInputBorder(),
      focusedErrorBorder: activeInputBorder(),
      focusedBorder: activeInputBorder(),
      filled: true,
      fillColor: Colors.grey[100]);
}

OutlineInputBorder errorInputBorder() {
  return OutlineInputBorder(
    //error가 나도 테두리 유지
      borderSide: BorderSide(
        color: Colors.redAccent,
      ),
      borderRadius: BorderRadius.circular(common_gap));
}

OutlineInputBorder activeInputBorder() {
  return OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black12,
      ),
      borderRadius: BorderRadius.circular(common_gap));
}