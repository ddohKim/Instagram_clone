import 'package:test_1/models/firestore/user_model.dart';

String getNewPostKey(UserModel userModel)=>"${DateTime.now().millisecondsSinceEpoch}_${userModel.userKey}";//unique한 key를 만들기 위해
