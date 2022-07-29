import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/constants/screen_size.dart';
import 'package:test_1/models/user_model_state.dart';
import 'package:test_1/screens/profile_screen.dart';
import 'package:test_1/widgets/rounded_avatar.dart';

class ProfileBody extends StatefulWidget {
  final Function() onMenuChanged; //menu button이 눌리면 실행되도록!

  const ProfileBody({Key? key, required this.onMenuChanged}) : super(key: key);

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody>
    with SingleTickerProviderStateMixin {
  //with는 class 자체를 가지고 오는것, singleticker..로 init의 vsync에 가르키기위해
  SelectedTab _selectedTab = SelectedTab.left;
  double _leftImagesPageMargin = 0;
  double _rightImagesPageMargin = size!.width;
  late AnimationController _iconAnimationController; //메뉴 아이콘이 바뀌는거 해주기 위해서 필요

  @override
  void initState() {
    //해당 state가 실행될때 이게 실행
    _iconAnimationController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: 300)); //vsync가 profilebodystate의 instance 가르킴
    super.initState();
  }

  @override
  void dispose() {
    //해당 state가 버려질때 이게 실행
    _iconAnimationController.dispose(); //불필요한 memory leak 을 막기 위해
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      //SafeArea 노치공간 보호
      child: Column(
          //직접 appbar 만들기
          crossAxisAlignment: CrossAxisAlignment.start,
          //crossAxis.start 는 왼쪽으로 정렬하게 만듬
          children: [
            _appbar(),
            Expanded(
              //customscrollview 가 펼쳐지게 해야 보임
              child: CustomScrollView(
                //scroll을 해줄때 좌우, 위아래 자유롭게 해주기위해 즉 list view와 grid view를 동시에 사용가능
                slivers: [
                  SliverList(
                    delegate:
                        SliverChildListDelegate(//sliverlist 쓰려면 그냥 이대로 따라하면됨
                            [
                      Row(
                        //프로필 사진 만들기
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(common_gap),
                            child: RoundedAvatar(
                              size: 80,
                            ),
                          ),
                          Expanded(
                            //table이 나머지 부분을 차지하기 위해
                            child: Padding(
                              padding: const EdgeInsets.only(right: common_gap),
                              child: Table(
                                //표 만들기
                                children: [
                                  TableRow(children: [
                                    _valueText('123'),
                                    _valueText('3443'),
                                    _valueText('1543'),
                                  ]),
                                  TableRow(children: [
                                    _lableText('Post'),
                                    _lableText('Followers'),
                                    _lableText('Following'),
                                  ])
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      _username(context),
                      _userBio(),
                      _editProfileBtn(),
                      _tabButtons(),
                      _selectedIndicator(),
                    ]),
                  ),
                  _imagesPager()
                ],
              ),
            )
          ]),
    );
  }

  Text _valueText(String value) => Text(value,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.bold));

  Text _lableText(String label) => Text(label,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w300));

  Row _appbar() {
    return Row(children: [
      SizedBox(width: 44),
      //text 정확히 가운데 맞추기
      Expanded(
          child: Text(
        'Profile',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      //글자가 대부분의 공간차지하기 > expanded
      IconButton(
          onPressed: () {
            _iconAnimationController.status == AnimationStatus.completed
                ? _iconAnimationController.reverse()
                : _iconAnimationController.forward(); //아이콘을 눌렀을 때 애니메이션 효과가 이미 보여졌다면 이걸 다시 전으로 돌리고 아니면 애니메이션 효과를 보여줌
            widget.onMenuChanged(); //stf에 있는 function을 가져오고 싶으면 widget. 을 이용
          },
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _iconAnimationController,
          ))
      //onpressed 지정해주면 검은색으로 변함(아이콘 색깔)
    ]);
  }

  SliverToBoxAdapter _imagesPager() {
    return SliverToBoxAdapter(
        child: Stack(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          transform: Matrix4.translationValues(_leftImagesPageMargin, 0, 0),
          //x값을 변화시켜 좌우로스크롤이가능하게
          curve: Curves.fastOutSlowIn,
          child: _images(0),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          transform: Matrix4.translationValues(_rightImagesPageMargin, 0, 0),
          //x값을 변화시켜 좌우로스크롤이가능하게
          curve: Curves.fastOutSlowIn,
          child: _images(30),
        ),
      ],
    ));

    //gridview를 사용하기 위해 slivertoboxadapter 를 이용하고
  }

  GridView _images(int A) {
    return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        //physics 는 gridview에서 스크롤을 하지 않기위해,
        shrinkWrap: true,
        //shrinkWrap false 는 크기를 지정하지 않은 부분도 차지해서 계속 스크롤이됨
        crossAxisCount: 3,
        childAspectRatio: 1,
        children: List.generate(
            30,
            (index) => CachedNetworkImage(
                fit: BoxFit.cover, //index를 받기 위해 $ 이용
                imageUrl: "https://picsum.photos/id/${index + A}/300/300")));
  }

  Widget _selectedIndicator() {
    return AnimatedContainer(
      //자동으로 애니메이션 구현가능
      duration: Duration(milliseconds: 300),
      alignment: _selectedTab == SelectedTab.left
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        height: 3,
        width: size!.width / 2,
        color: Colors.black87,
      ),
      curve: Curves.fastOutSlowIn,
    ); //애니메이션 효과를 주는것
  }

  Row _tabButtons() {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceAround, //icon 위치를 가운데로 클릭할수 있는 공간은 딱 그 아이콘만 가능
      children: [
        Expanded(
          child: IconButton(
            onPressed: () {
              _tabSelected(SelectedTab.left);
            },
            icon: ImageIcon(
                AssetImage(
                  'assets/images/grid.png',
                ),
                color: _selectedTab == SelectedTab.left
                    ? Colors.black
                    : Colors.black26),
          ),
        ),
        Expanded(
          child: IconButton(
            onPressed: () {
              _tabSelected(SelectedTab.right);
            },
            icon: ImageIcon(
                AssetImage(
                  'assets/images/saved.png',
                ),
                color: _selectedTab == SelectedTab.left
                    ? Colors.black26
                    : Colors.black),
          ),
        )
      ],
    );
  }

  _tabSelected(SelectedTab selectedTab) //tab 선택에 따라 변화
  {
    setState(() {
      switch (selectedTab) {
        case SelectedTab.left:
          _selectedTab = SelectedTab.left; //setstate로 상태변화를 줌
          _leftImagesPageMargin = 0;
          _rightImagesPageMargin = size!.width;
          break;
        case SelectedTab.right:
          _selectedTab = SelectedTab.right;
          _leftImagesPageMargin = -size!.width;
          _rightImagesPageMargin = 0;
          break;
      }
    });
  }

  Padding _editProfileBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: common_gap, vertical: common_xxs_gap),
      child: SizedBox(
        //size를 부여
        height: 24,
        child: OutlineButton(
            onPressed: () {},
            borderSide: BorderSide(color: Colors.black45),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6)), //borderside는 바깥 테두리
            child: Text('Edit Profile',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _username(BuildContext context) {
    UserModelState userModelState=Provider.of<UserModelState>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: common_gap),
      child: Text(
        userModelState==null||userModelState.userModel==null?"":
        userModelState.userModel!.username,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _userBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: common_gap),
      child: Text(
        'Do my best!',
        style: TextStyle(fontWeight: FontWeight.w400),
      ), //w400 글씨체 조금 약하
    );
  }
}

enum SelectedTab { left, right }
