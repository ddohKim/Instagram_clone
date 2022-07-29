import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:test_1/models/firestore/user_model.dart';

class UserModelState extends ChangeNotifier {
   UserModel? _userModel;

   StreamSubscription<
      UserModel> ?_currentStreamSub; //logout이 되면 더이상 구독을 하지 않아 데이터를 지우기 위해
  UserModel? get userModel => _userModel;

  set userModel(UserModel? userModel) {
    //usermodel이 바뀌면 새로운 값을 받아옴
    _userModel = userModel!;
    notifyListeners();
  }

  set currentStreamSub(StreamSubscription<UserModel> currentStreamSub) =>
      _currentStreamSub =
          currentStreamSub; //currentStreamSub를 받아와서 _currentStreamSub에 저장

  clear()async{
    if(_currentStreamSub!=null) {
      await _currentStreamSub!.cancel(); //cancel이 future이기 때문
    }
    _currentStreamSub=null;
    _userModel=null;
  }

  bool amIFollowingThisUser(String otherUserKey){
    return _userModel!.followings.contains(otherUserKey); //만약 다른유저의 키를 내가 가지고 있으면 팔로우하고 있음
  }
}