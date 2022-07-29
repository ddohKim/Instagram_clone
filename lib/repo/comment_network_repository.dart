import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_1/constants/firestore_keys.dart';
import 'package:test_1/models/firestore/comment_model.dart';
import 'package:test_1/repo/helper/transformers.dart';

//Create a comment
//1. get post ref 2. get post snapshot 3. get/create comment collection 4. run transaction(1. upload comment data into comment collection, 2. last comment data and num of comment in the post document)
class CommentNetWorkRepository with Transformers {
  Future<void> createNewComment(
      String postKey, Map<String, dynamic> commentData) async {
    final DocumentReference postRef =
        FirebaseFirestore.instance.collection(COLLECTION_POSTS).doc(postKey);
    final DocumentSnapshot postSnapshot =
        await postRef.get(); //future로 받아와서 await 사용
    final DocumentReference commentRef = postRef
        .collection(COLLECTION_COMMENTS)
        .doc(); //subcollection을 생성하거나 이미 생성된것을 가져옴

    return FirebaseFirestore.instance.runTransaction((tx) async {
      if (postSnapshot.exists) {
        //postSnapshot이 존재해야 comment를 달 수 있음
        await tx.set(commentRef, commentData); //commentRef 안에 commentData를 저장해줌
        int numofComments = postSnapshot[KEY_NUMOFCOMMENTS];
        await tx.update(postRef, {
          KEY_NUMOFCOMMENTS: numofComments + 1,
          KEY_LASTCOMMENT: commentData[KEY_COMMENT],
          KEY_LASTCOMMENTTIME: commentData[KEY_COMMENTTIME],
          KEY_LASTCOMMENTOR: commentData[KEY_USERNAME]
        });
      }
    });
  }

  Stream<List<CommentModel>> fetchAllComments(String postKey) {
    return FirebaseFirestore.instance
        .collection(COLLECTION_POSTS)
        .doc(postKey)
        .collection(COLLECTION_COMMENTS)
        .orderBy(KEY_COMMENTTIME,descending: true)// descending으로 글자가 맨아래 오도록
        .snapshots()
        .transform(toComments); // orderBy는 가지고 오기 전에 미리 순서를 정해서 가져옴
  }
}

CommentNetWorkRepository commentNetWorkRepository=CommentNetWorkRepository();