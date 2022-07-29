import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_1/constants/firestore_keys.dart';
import 'package:test_1/models/firestore/user_model.dart';
import 'package:test_1/repo/helper/generate_post_key.dart';
import 'package:test_1/repo/helper/transformers.dart';

class UserNetworkRepository with Transformers{ //with를 통해 transformer 안에 있는 모든 변수를 사용한다고 알려줌
  Future <void> attemptCreateUser({String? userKey, String? email}) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection(
        COLLECTION_USERS).doc(userKey);

    DocumentSnapshot snapshot = await userRef.get();
    if (!snapshot.exists) {
      return await userRef.set(UserModel.getMapForCreateUser(email!));
    }
  }

  Stream<UserModel> getUserModelStream(String userKey) {
    return FirebaseFirestore.instance.collection(COLLECTION_USERS)
        .doc(userKey)
        .snapshots().transform(toUser); //snapshots()를 통해 DocumentSnapshot이 바뀔때마다 정보를 가져와줌(stream)
  }

  Stream<List<UserModel>> getAllUsersWithoutMe(){
    return FirebaseFirestore.instance.collection(COLLECTION_USERS).snapshots().transform(toUsersExceptMe); //.snapshot은 COLLECTION_USER에 있는 모든 유저를 가져옴
  }

 Future<void> followUser({String? myUserKey,String? otherUserKey})async{
    final DocumentReference myUserRef=FirebaseFirestore.instance.collection(COLLECTION_USERS).doc(myUserKey); //myuser와 otheruser의 reference가져오기
    final DocumentSnapshot mySnapshot=await myUserRef.get(); //snapshot가져오기
    final DocumentReference otherUserRef=FirebaseFirestore.instance.collection(COLLECTION_USERS).doc(otherUserKey);
    final DocumentSnapshot otherSnapshot=await otherUserRef.get();
    FirebaseFirestore.instance.runTransaction((tx)async{
      if(mySnapshot.exists&&otherSnapshot.exists)
        {
          await tx.update(myUserRef, {KEY_FOLLOWINGS:FieldValue.arrayUnion([otherUserKey])});
          int currentFollowers=otherSnapshot[KEY_FOLLOWERS];
          await tx.update(otherUserRef, {KEY_FOLLOWERS: currentFollowers+1});
        }
    });
 }

  Future<void> unfollowUser({String? myUserKey,String? otherUserKey})async{
    final DocumentReference myUserRef=FirebaseFirestore.instance.collection(COLLECTION_USERS).doc(myUserKey); //myuser와 otheruser의 reference가져오기
    final DocumentSnapshot mySnapshot=await myUserRef.get(); //snapshot가져오기
    final DocumentReference otherUserRef=FirebaseFirestore.instance.collection(COLLECTION_USERS).doc(otherUserKey);
    final DocumentSnapshot otherSnapshot=await otherUserRef.get();
    FirebaseFirestore.instance.runTransaction((tx)async{
      if(mySnapshot.exists&&otherSnapshot.exists)
      {
        await tx.update(myUserRef, {KEY_FOLLOWINGS:FieldValue.arrayRemove([otherUserKey])});
        int currentFollowers=otherSnapshot[KEY_FOLLOWERS];
        await tx.update(otherUserRef, {KEY_FOLLOWERS: currentFollowers-1});
      }
    });
  }
}

UserNetworkRepository userNetworkRepository = UserNetworkRepository();