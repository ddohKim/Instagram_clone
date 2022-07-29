import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/firestore/post_model.dart';
import 'package:test_1/models/firestore/user_model.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/repo/image_network_repository.dart';
import 'package:test_1/repo/post_network_repository.dart';
import 'package:test_1/widgets/my_progress_indicator.dart';

class SharePostScreen extends StatefulWidget {
  final File imageFile;
  final String? postKey;

  SharePostScreen(this.imageFile, {Key? key, @required this.postKey})
      : super(key: key);

  @override
  State<SharePostScreen> createState() => _SharePostScreenState();
}

class _SharePostScreenState extends State<SharePostScreen> {
  TextEditingController _textEditingController = TextEditingController();

  List<String> _tagItems = ['hi', 'hello', 'bye'];

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New Post'),
          actions: [
            FlatButton(
                onPressed: sharePostProcedure,
                child: Text(
                  "Share",
                  textScaleFactor: 1.4,
                  style: TextStyle(color: Colors.cyanAccent),
                ))
          ],
        ),
        body: ListView(
          children: [
            _captionWithImage(),
            _divider,
            _sectionButton('Tag people'),
            _divider,
            _sectionButton('Add Location'),
            _tags(),
            SizedBox(
              height: common_xxs_gap,
            ),
            _divider,
            SectionSwitch('Facebook'),
            SectionSwitch('Instagram'),
            SectionSwitch('Tumblr'),
            _divider,
          ],
        ));
  }

  void sharePostProcedure() async {
    //이미지 크기를 줄이는 동안에 loading화면이 나오도록
    showModalBottomSheet(
      context: context,
      builder: (_) => MyProgressIndicator(
        containerSize: size!.width,
      ),
      isDismissible: false,
      enableDrag: false,
    ); //context사용을 안해서 _ 만 넣어줌, 색다른 방법으로 Loading화면 보이게
    await imageNetworkRepository.uploadImage(widget.imageFile,
        postKey: widget.postKey!);
    UserModel? usermodel =
        Provider.of<UserModelState>(context, listen: false)
            .userModel;
    await postNetWorkRepository.createNewPost(
        widget.postKey!,
        PostModel.getMapForCreatePost(
            userKey: usermodel!.userKey,
            username: usermodel.username,
            caption: _textEditingController.text));
    String postImgLink = await imageNetworkRepository
        .getPostImageUrl(widget.postKey!); //postimage링크를 가져옴
    await postNetWorkRepository.updatePostImageUrl(
        postKey: widget.postKey, postImg: postImgLink);
    Navigator.of(context).pop(); //showModalBottomSheet이 사라짐
    Navigator.of(context).pop(); //sharepostscreen에서 나가는 것
  }
  
  Tags _tags() {
    return Tags(
      horizontalScroll: true,
      itemCount: _tagItems.length,
      heightHorizontalScroll: 30,
      itemBuilder: (index) => ItemTags(
        index: index,
        title: _tagItems[index],
        activeColor: Colors.grey[200],
        textActiveColor: Colors.black,
        borderRadius: BorderRadius.circular(4),
        elevation: 2,
        splashColor: Colors.grey[800],
      ),
    );
  }

  Divider get _divider => Divider(
        //선나누기
        color: Colors.grey[300],
        thickness: 1,
        height: 1,
      );

  ListTile _sectionButton(String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
      trailing: Icon(Icons.navigate_next),
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: common_gap),
    );
  }

  ListTile _captionWithImage() {
    return ListTile(
      contentPadding:
          EdgeInsets.symmetric(vertical: common_gap, horizontal: common_gap),
      leading: Image.file(widget.imageFile,
          width: size!.width / 6, height: size!.width / 6, fit: BoxFit.cover),
      title: TextField(
        controller: _textEditingController, //텍스팅할수 있게
        autofocus: true, //자동으로 커서가 깜박이도록 타이핑가능하게
        decoration: InputDecoration(
            hintText: 'Write a caption...', border: InputBorder.none),
      ),
    );
  }
}

class SectionSwitch extends StatefulWidget {
  String _title;

  SectionSwitch(
    this._title, {
    Key? key,
  }) : super(key: key);

  @override
  State<SectionSwitch> createState() => _SectionSwitchState();
}

class _SectionSwitchState extends State<SectionSwitch> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget._title,
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
      trailing: CupertinoSwitch(
        value: checked,
        onChanged: (onValue) {
          setState(() {
            checked = onValue;
          });
        },
      ),
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: common_gap),
    );
  }
}
