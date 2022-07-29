import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/firestore/post_model.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/repo/image_network_repository.dart';
import 'package:test_1/repo/post_network_repository.dart';
import 'package:test_1/screens/comments_screen.dart';
import 'package:test_1/widgets/comment.dart';
import 'package:test_1/widgets/my_progress_indicator.dart';
import 'package:test_1/widgets/rounded_avatar.dart';

class Post extends StatelessWidget {
  final PostModel postModel;

  Post(
    this.postModel, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _postHeader(),
        _postimage(),
        _postActions(context),
        _postLikes(),
        _postCaption(),
        _lastComment(),
        _moreComments(context),
      ],
    );
  }

  Widget _postHeader() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(common_xxs_gap),
          child: RoundedAvatar(),
        ),
        Expanded(child: Text(postModel.username)),
        IconButton(
            onPressed: null,
            icon: Icon(Icons.more_horiz, color: Colors.black87))
      ],
    );
  }

  Widget _postimage() {
    Widget progress = MyProgressIndicator(
      containerSize: size!.width,
    );
    return CachedNetworkImage(
      imageUrl: postModel.postImg,
      //dynamic을 string으로 바꿔서 링크 사용 //'https://picsum.photos/id/${widget.number}/2000/2000',
      placeholder: (BuildContext context, String url) {
        return progress; //loading...
      },
      imageBuilder: (BuildContext context, ImageProvider imageProvider) {
        return AspectRatio(
            aspectRatio: 1,
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.fill))));
      },
    );
  }

  Row _postActions(BuildContext context) {
    return Row(children: [
      IconButton(
          onPressed: null,
          icon: ImageIcon(AssetImage('assets/images/bookmark.png')),
          color: Colors.black45),
      IconButton(
          onPressed: () {
            _goToComments(context);
          },
          icon: ImageIcon(AssetImage('assets/images/comment.png')),
          color: Colors.black45),
      IconButton(
          onPressed: null,
          icon: ImageIcon(AssetImage('assets/images/direct_message.png')),
          color: Colors.black45),
      Spacer(),
      Consumer<UserModelState>(
        builder: (BuildContext context, UserModelState userModelState, Widget? child) {
          return IconButton(
              onPressed: () {
                postNetWorkRepository.toggleLike(postModel.postKey, userModelState.userModel!.userKey);
              },
              icon: ImageIcon(
                AssetImage(postModel.numOfLikes.contains(
                        userModelState
                            .userModel!
                            .userKey)
                    ? 'assets/images/heart_selected.png'
                    : 'assets/images/heart.png'),
                color: Colors.redAccent,
              ),
              color: Colors.black45);
        },
      ),
    ]);
  }

  Padding _postLikes() {
    return Padding(
      padding: EdgeInsets.only(left: common_gap),
      child: Text(
        '${postModel.numOfLikes == null ? 0 : postModel.numOfLikes.length} likes',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _postCaption() {
    return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: common_gap, vertical: common_xxs_gap),
        child: Comment(
          showImage: false,
          username: postModel.username,
          text: postModel.caption,
        ));
  }

  Widget _lastComment() {
    return Padding(
        padding: const EdgeInsets.only(
            left: common_gap, right: common_gap, top: common_xxs_gap),
        child: Comment(
          showImage: false,
          username: postModel.lastCommentor,
          text: postModel.lastComment,
        ));
  }

  Widget _moreComments(BuildContext context) {
    return Visibility(
      visible:
          (postModel.numOfComments != null && postModel.numOfComments >= 2),
      child: GestureDetector(
        onTap: () {
          _goToComments(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: common_gap),
          child: Text(
            "${postModel.numOfComments - 1} more comments...",
          ),
        ),
      ),
    );
  }

  _goToComments(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return CommentsScreen(
        postKey: postModel.postKey,
      );
    }));
  }
}
