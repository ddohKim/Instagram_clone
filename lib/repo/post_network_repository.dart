import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_1/constants/firestore_keys.dart';
import 'package:test_1/models/firestore/post_model.dart';
import 'package:test_1/repo/helper/transformers.dart';

class PostNetWorkRepository with Transformers {
  Future<void> createNewPost(
      String postKey, Map<String, dynamic> postData) async {
    final DocumentReference postRef = FirebaseFirestore.instance
        .collection(COLLECTION_POSTS)
        .doc(postKey); //reference에 postKey 받아옴
    final DocumentSnapshot postSnapshot = await postRef.get(); //비어있는 상태
    final DocumentReference userRef = FirebaseFirestore.instance
        .collection(COLLECTION_USERS)
        .doc(postData[KEY_USERKEY]);

    return FirebaseFirestore.instance.runTransaction((Transaction tx) async {
      if (!postSnapshot.exists) {
        await tx.set(postRef, postData); //postRef 에 postData 업로드
        await tx.update(userRef, {
          KEY_MYPOSTS: FieldValue.arrayUnion([postKey])
        }); //userref에 MYPOST UPDATE, 방법은 일단 외우기
      }
    });
  }

  Future<void> updatePostImageUrl({String? postImg, String? postKey}) async {
    final DocumentReference postRef = FirebaseFirestore.instance
        .collection(COLLECTION_POSTS)
        .doc(postKey); //reference에 postKey 받아옴
    final DocumentSnapshot postSnapshot = await postRef.get();
    if (postSnapshot.exists) {
      await postRef.update({KEY_POSTIMG: postImg}); //postImg 업데이트
    }
  }

  Stream<List<PostModel>> getPostsFromSpecificUser(String userKey) {
    return FirebaseFirestore.instance
        .collection(COLLECTION_POSTS)
        .where(KEY_USERKEY, isEqualTo: userKey)
        .snapshots().transform(toPosts); //where은 collection 안에서 where속에 일치하는 부분만 가지고 오는것
  }


  Stream<List<PostModel>> ?fetchPostsFroAllFollowers(List<dynamic> followings){ //1.Collection reference 2.create stream for every following users 3.Put all the post stream into the list 4. usgin Rxdart, combine all the stream
    final CollectionReference collectionReference=FirebaseFirestore.instance.collection(COLLECTION_POSTS);
    List<Stream<List<PostModel>>> streams=[];

    for(final following in followings){
      streams.add(collectionReference.where(KEY_USERKEY,isEqualTo: following).snapshots().transform(toPosts));
    }
    return CombineLatestStream.list<List<PostModel>>(streams).transform(combineListOfPosts).transform(latestToTop);//단점은 9개 까지 밖에 안됨
  }


  Future<void> toggleLike(String postKey, String userKey) async{//1.DocumentReference postRef 2.DocumentSnapshot postSnapshot 3.postSnapshot contain my userKey? if yes? remove my userKey, no? add my userKey
    final DocumentReference postRef=FirebaseFirestore.instance.collection(COLLECTION_POSTS).doc(postKey);
    final DocumentSnapshot postSnapshot=await postRef.get(); //future로 받아져서 await 사용
    if(postSnapshot.exists){
      if(postSnapshot[KEY_NUMOFLIKES].contains(userKey)){
        postRef.update({KEY_NUMOFLIKES:FieldValue.arrayRemove([userKey])}); //해당유저키를 없애줌
      }else{
        postRef.update({KEY_NUMOFLIKES:FieldValue.arrayUnion([userKey])}); //해당유저키를 넣어줌
      }
    }
  }
}

PostNetWorkRepository postNetWorkRepository = PostNetWorkRepository();
