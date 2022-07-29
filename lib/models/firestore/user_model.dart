import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_1/constants/firestore_keys.dart';

class UserModel {
  //usermodel을 한번 생성하고 나서는 변경이 불가능하게 final로 써줌
  final String userKey;
  final String profileImg;
  final String email;
  final List<dynamic> myPosts; //dynamic과 object의 차이점 유튜브에서 확인해보기
  final int followers;
  final List<dynamic> likedPosts;
  final String username;
  final List<dynamic> followings;
  final DocumentReference reference; //해당 document가 어디에 위치에 있는지 여기에 저장을 해줌

  UserModel.fromMap(Map<String, dynamic> map, this.userKey, {required this.reference}) //reference는 받아도 되고 안받아도 되는 옵션값으로 해둠 , firebase에서 JSON데이터 받기, JSON 역시 유튜브에서 확인해보기
      : profileImg = map[KEY_PROFILEING],
        username = map[KEY_USERNAME],
        email = map[KEY_EMAIL],
        likedPosts = map[KEY_LIKEPOSTS],
        followers = map[KEY_FOLLOWERS],
        followings = map[KEY_FOLLOWINGS],
        myPosts = map[KEY_MYPOSTS];
  UserModel.fromSnapshot(DocumentSnapshot snapshot) //DocumentSnapshot은 Document data라 생각하면 됨
  : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id,reference: snapshot.reference);

  static Map<String, dynamic> getMapForCreateUser(String email){
    Map<String, dynamic> map=Map();
    map[KEY_PROFILEING]="";
    map[KEY_USERNAME]=email.split("@")[0]; //@ 앞글자를 가져와서 string 으로 만듬
    map[KEY_EMAIL]=email;
    map[KEY_LIKEPOSTS]=[];
    map[KEY_FOLLOWINGS]=[];
    map[KEY_FOLLOWERS]=0;
    map[KEY_MYPOSTS]=[];
    return map;
  }
}
