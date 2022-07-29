import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/firestore/user_model.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/repo/user_network_repository.dart';
import 'package:test_1/widgets/my_progress_indicator.dart';
import 'package:test_1/widgets/rounded_avatar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searching'),
        toolbarTextStyle: TextStyle(fontStyle: FontStyle.italic),
      ),
      body: StreamBuilder<List<UserModel>>(
          stream: userNetworkRepository.getAllUsersWithoutMe(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SafeArea(child: Consumer<UserModelState>(
                builder: (BuildContext context, UserModelState myUserModelState,
                    Widget? Child) {
                  return ListView.separated(
                      itemBuilder: (context, index) {
                        UserModel otherUser =
                            snapshot.data![index]; //userModel 들을 순차적으로 가져옴
                        bool amIFollowing =
                            Provider.of<UserModelState>(context, listen: false)
                                .amIFollowingThisUser(otherUser.userKey);
                        return ListTile(
                            onTap: () {
                              setState(() {
                                amIFollowing
                                    ? userNetworkRepository.unfollowUser(
                                        myUserKey:
                                            myUserModelState.userModel!.userKey,
                                        otherUserKey: otherUser.userKey)
                                    : userNetworkRepository.followUser(
                                        myUserKey:
                                            myUserModelState.userModel!.userKey,
                                        otherUserKey: otherUser.userKey);
                              });
                            },
                            leading: RoundedAvatar(),
                            title: Text(otherUser.username),
                            subtitle: Text(
                                'This is user bio of ${otherUser.username}'),
                            trailing: Container(
                              alignment: Alignment.center,
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: amIFollowing
                                      ? Colors.blue[50]
                                      : Colors.red[50],
                                  border: Border.all(
                                    color:
                                        amIFollowing ? Colors.blue : Colors.red,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: FittedBox(
                                child: Text(
                                  amIFollowing ? 'following' : 'unfollowing',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ));
                      },
                      separatorBuilder: (context, index) {
                        return Divider(color: Colors.grey);
                      }, //간격 크기 나눠줌
                      itemCount: snapshot.data!.length);
                },
              ) //listtile은 이미 틀이 정해져 있음
                  );
            } else {
              return MyProgressIndicator(
                containerSize: size!.width,
              );
            }
          }),
    );
  }
}
