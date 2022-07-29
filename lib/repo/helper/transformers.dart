import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_1/models/firestore/comment_model.dart';
import 'package:test_1/models/firestore/post_model.dart';
import 'package:test_1/models/firestore/user_model.dart';

class Transformers {
  final toUser = StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
      UserModel>.fromHandlers(handleData: (snapshot, sink) async {
    sink.add(UserModel.fromSnapshot(snapshot));
  });

  final toUsersExceptMe = StreamTransformer< //QuerySnapshot을 List<UserModel>로 바꿔줌
      QuerySnapshot<Map<String, dynamic>>,
      List<UserModel>>.fromHandlers(handleData: (snapshot, sink) async {
    List<UserModel> users = [];

    User? _firebaseUser=await FirebaseAuth.instance.currentUser;

    snapshot.docs.forEach((documentSnapshot) {
      if(_firebaseUser!.uid!=documentSnapshot.id) //자기 아이디에서는( 자기것) post올라오는 것을 제외시키기 위해
      users.add(UserModel.fromSnapshot(documentSnapshot));
    });
    sink.add(users);
  });

  final toPosts = StreamTransformer< //QuerySnapshot을 List<PostModel>로 바꿔줌
      QuerySnapshot<Map<String, dynamic>>,
      List<PostModel>>.fromHandlers(handleData: (snapshot, sink) async {
    List<PostModel> posts = [];

    snapshot.docs.forEach((documentSnapshot) {
        posts.add(PostModel.fromSnapshot(documentSnapshot));
    });
    sink.add(posts);
  });


  final combineListOfPosts = StreamTransformer< //List<List<PostModel>>을 하나씩 다 꺼내서 List<PostModel> posts 로 넣어줌
      List<List<PostModel>>,
      List<PostModel>>.fromHandlers(handleData: (listOfPosts, sink) async {
    List<PostModel> posts = [];

    for(final postList in listOfPosts){
      posts.addAll(postList);
    }
    sink.add(posts);
  });

  final latestToTop = StreamTransformer< //QuerySnapshot을 List<PostModel>로 바꿔줌
      List<PostModel>,
      List<PostModel>>.fromHandlers(handleData: (posts, sink) async {

        posts.sort((a,b)=>b.postTime.compareTo(a.postTime)); //postTime이 큰 값이 위로 올라가도록
      sink.add(posts);
  });

  final toComments = StreamTransformer< //QuerySnapshot을 List<CommentModel>로 바꿔줌
      QuerySnapshot<Map<String, dynamic>>,
      List<CommentModel>>.fromHandlers(handleData: (snapshot, sink) async {
    List<CommentModel> comments = [];

    snapshot.docs.forEach((documentSnapshot) {
      comments.add(CommentModel.fromSnapshot(documentSnapshot));
    });
    sink.add(comments);
  });

}
