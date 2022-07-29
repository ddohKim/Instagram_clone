import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/models/firebase_auth_state.dart';
import 'package:test_1/screens/auth_screen.dart';

class ProfileSideMenu extends StatelessWidget {
  final double menuWidth;

  const ProfileSideMenu(this.menuWidth,{Key? key, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        //크기 지정
        width: menuWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(//아이콘과 글씨를 같이 쓰도록
              title: Text('Setting',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            ListTile(//아이콘과 글씨를 같이 쓰도록
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.black87,
              ),
              title: Text('Log out'),
              onTap: (){ Provider.of<FirebaseAuthState>(context, listen: false).signOut();
              },
            )
          ],
        ),
      ),
    );
  }
}
