import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/models/firestore/comment_model.dart';
import 'package:test_1/models/firestore/user_model.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/repo/comment_network_repository.dart';
import 'package:test_1/widgets/comment.dart';

class CommentsScreen extends StatefulWidget {
  final String postKey;

  const CommentsScreen({Key? key, required this.postKey}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {

  TextEditingController _textEditingController = TextEditingController(); //글자를 쓰기위해 이런거 사용
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
        body: Padding(
          padding: const EdgeInsets.all(common_xxs_gap),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(child: StreamProvider<List<CommentModel>>.value(
                  value: commentNetWorkRepository.fetchAllComments(
                      widget.postKey),
                  initialData: [],
                  child: Consumer<List<CommentModel>>(
                      builder: (BuildContext context, List<CommentModel> comments,
                          Widget? child) {
                        return ListView.separated(reverse: true,
                            itemBuilder: (context, index) {
                          return Comment(username: comments[index].username, text: comments[index].comment,dateTime: comments[index].commentTime,showImage: true,);
                        }, separatorBuilder: (context, index) {return Padding(padding: EdgeInsets.all(common_xxs_gap));}, itemCount: comments==null?0:comments.length);}
                        )
                        )
                        )
                        ,
                      Divider(height: 1,thickness: 1,color: Colors.grey[400],),Row(
                  children: [
                  Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: common_gap),
                  child: TextFormField(controller: _textEditingController,
                    autofocus: true,//commentscreen에 들어갈때 자동으로 키보드 나오도록
                    cursorColor: Colors.black54,
                    decoration: InputDecoration(
                        hintText: 'Add a comment', border: InputBorder.none),
                    validator: (String? value) {
                      if (value!.isEmpty)
                        return 'Input somethiing';
                      else
                        return null;
                    },),
                )),
                FlatButton(onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    UserModel? usermodel=Provider.of<UserModelState>(context, listen:false).userModel;
                    Map<String, dynamic> newComment=CommentModel.getMapForNewComment(usermodel!.userKey, usermodel.username, _textEditingController.text);
                    await commentNetWorkRepository.createNewComment(widget.postKey, newComment);
                    _textEditingController.clear();
                    //todo: push a comment
                  }
                }, child: Text('Post')),

              ],
            ), SizedBox(height: 20),
            ],
          )
    ),
        ),);
  }
}
