import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/firestore/post_model.dart';
import 'package:test_1/models/firestore/user_model.dart';
import 'package:test_1/repo/post_network_repository.dart';
import 'package:test_1/repo/user_network_repository.dart';
import 'package:test_1/widgets/my_progress_indicator.dart';
import 'package:test_1/widgets/post.dart';

class FeedScreen extends StatelessWidget {
  final List<dynamic> followings;

  const FeedScreen(this.followings, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<PostModel>>.value(
      initialData: [],
      value: postNetWorkRepository.fetchPostsFroAllFollowers(followings),
      child: Consumer<List<PostModel>>(
        builder: (BuildContext context, List<PostModel> posts, Widget? child) {
          if (posts == null || posts.isEmpty)
            return MyProgressIndicator(containerSize: size!.width,);
          else {
            return Scaffold(
              appBar: CupertinoNavigationBar(
                leading: IconButton(
                    onPressed: null,
                    icon: Icon(CupertinoIcons.photo_camera_solid,
                        color: Colors.black87)),
                middle: Text(
                  'somsatang',
                  style: TextStyle(
                      fontFamily: 'VeganStyle', color: Colors.black87),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                          AssetImage('assets/images/actionbar_camera.png'),
                          color: Colors.black87),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: ImageIcon(
                          AssetImage('assets/images/direct_message.png'),
                          color: Colors.black87),
                    )
                  ],
                ),
              ),
              body:
                  ListView.builder(itemBuilder: (context,index)=>feedListBuilder(context, posts[index]), itemCount: posts.length),
            );
          }
        },
      ),
    );
  }

  Widget feedListBuilder(BuildContext context, PostModel postModel) {
    return Post(postModel);
  }
}
