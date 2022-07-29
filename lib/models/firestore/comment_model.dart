import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_1/constants/firestore_keys.dart';

class CommentModel{
  final String username;
  final String userKey;
  final String comment;
  final DateTime commentTime;
  final String commentKey;
  final DocumentReference reference;

  CommentModel.fromMap(Map<String, dynamic> map, this.commentKey, {required this.reference}) //reference는 받아도 되고 안받아도 되는 옵션값으로 해둠 , firebase에서 JSON데이터 받기, JSON 역시 유튜브에서 확인해보기
      : username = map[KEY_USERNAME],
        userKey= map[KEY_USERKEY],
        comment = map[KEY_COMMENT],
        commentTime=map[KEY_COMMENTTIME]==null?DateTime.now().toUtc():(map[KEY_COMMENTTIME] as Timestamp).toDate();
  CommentModel.fromSnapshot(DocumentSnapshot snapshot) //DocumentSnapshot은 Document data라 생각하면 됨
      : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id,reference: snapshot.reference);

  static Map<String, dynamic> getMapForNewComment(String userKey, String username, String comment){
    Map<String, dynamic> map=Map();
    map[KEY_USERKEY]=userKey;
    map[KEY_USERNAME]=username; //@ 앞글자를 가져와서 string 으로 만듬
    map[KEY_COMMENT]=comment;
    map[KEY_COMMENTTIME]=DateTime.now().toUtc();
    return map;
  }
}

