import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_1/constants/firestore_keys.dart';

class PostModel {
  final String postKey;
  final String userKey;
  final String username;
  final String postImg;
  final List<dynamic> numOfLikes; //좋아요를 취소하고 다시 누를수 있기 때문에 dynamic으로 해줌, userKey를 받아와서 List 길이를 측정
  final String caption;
  final String lastCommentor;
  final String lastComment;
  final DateTime lastCommentTime;
  final int numOfComments;
  final DateTime postTime;
  final DocumentReference reference;



  PostModel.fromMap(Map<String, dynamic> map, this.postKey, {required this.reference}) //postKey, reference는 아래 fromSnapShot에서 직접 추출 //reference는 받아도 되고 안받아도 되는 옵션값으로 해둠 , firebase에서 JSON데이터 받기, JSON 역시 유튜브에서 확인해보기
      : userKey=map[KEY_USERKEY],
        username=map[KEY_USERNAME],
        postImg=map[KEY_POSTIMG],
        numOfLikes=map[KEY_NUMOFLIKES],
        caption=map[KEY_CAPTION],
        lastCommentor=map[KEY_LASTCOMMENTOR],
        lastComment=map[KEY_LASTCOMMENT],
        lastCommentTime=map[KEY_LASTCOMMENTTIME]==null?DateTime.now().toUtc():(map[KEY_LASTCOMMENTTIME] as Timestamp).toDate(), // LASTCOMMENTTIME이 null이면 에러나지 않기 위해 현재시간을 넣어줌//commenttime이 firebasestore에서 올때 string으로 오는데 이걸 timestamp로 바꾸고 다시 DateTime으로 변환
        numOfComments=map[KEY_NUMOFCOMMENTS],
        postTime=map[KEY_POSTTIME]==null?DateTime.now().toUtc():(map[KEY_POSTTIME] as Timestamp).toDate();

  PostModel.fromSnapshot(DocumentSnapshot snapshot) //DocumentSnapshot은 Document data라 생각하면 됨,//postKey, reference는 아래 fromSnapShot에서 직접 추출
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id,reference: snapshot.reference);

  static Map<String, dynamic> getMapForCreatePost({String? userKey,String? username,String? caption }){
    Map<String, dynamic> map=Map();
    map[KEY_USERKEY]= userKey;
    map[KEY_USERNAME]= username;
    map[KEY_POSTIMG]= "";
    map[KEY_NUMOFLIKES]= [];
    map[KEY_CAPTION]= caption;
    map[KEY_LASTCOMMENTOR]= "";
    map[KEY_LASTCOMMENT]= "";
    map[KEY_LASTCOMMENTTIME]= DateTime.now().toUtc();
    map[KEY_NUMOFCOMMENTS]= 0;
    map[KEY_POSTTIME]= DateTime.now().toUtc();
    return map;
  }
}