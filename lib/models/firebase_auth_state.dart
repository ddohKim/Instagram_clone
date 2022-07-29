import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:test_1/repo/user_network_repository.dart';
import 'package:test_1/utils/simple_snackbar.dart';

class FirebaseAuthState extends ChangeNotifier {
  //해당 state가 변경되었으니 이에 맞게 디스플레이를 바꿔줘라 FirebaseUser=>User, AuthResult=>UserCredential, currentUser()=>currentUser, onAuthStateChanged=>authStateChanges()
  FirebaseAuthStatus _firebaseAuthStatus = FirebaseAuthStatus.progress;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _firebaseUser;
  FacebookLogin? _facebookLogin;

  void watchAuthChange() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      //받아오는 firebaseUser와 _firebaseUser가 일치하는지 안하는지 확인(안하면 _firebaseUser 업데이트)
      if (firebaseUser == null && _firebaseUser == null) {
        changeFirebaseAuthStatus();
        return;
      } else if (firebaseUser != _firebaseUser) {
        _firebaseUser = firebaseUser;
        changeFirebaseAuthStatus(); //firebaseAuthStats를 보내지 않음
      }
      });
  }

  void registerUser(BuildContext context,
      {required String email, required String password}) async {
    //firebase에 email과 password 저장
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress); //loading화면
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .catchError((error) {
      print(error); //trim은 띄어쓰기 제거
      String _message = "";
      switch (error.code) {
        case 'email-already-in-use':
          _message = "이미 있는 이메일주소입니다";
          break;
        case '  invalid-email':
          _message = "이메일주소가 올바르지 않습니다";
          break;
        case 'operation-not-allowed':
          _message = "패스워드가 이상합니다";
          break;
      }
      SnackBar snackBar = SnackBar(
        content: Text(_message),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });
    _firebaseUser = userCredential.user; //로그인이 잘 되었을때 firebaseUser가 생성됨
    if (_firebaseUser == null) {
      SnackBar snackBar = SnackBar(
        content: Text("다시 시도해주세요"),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      await userNetworkRepository.attemptCreateUser(
          userKey: _firebaseUser!.uid,
          email: _firebaseUser!
              .email); //firestore로 데이터 보내주기, uid는 uique하기 때문에 userKey로 사용가능
    }
  }

  void login(BuildContext context,
      {required String email, required String password}) async {
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress); //loading화면
    UserCredential ?userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .catchError((error) {
      print(error);
      String _message = "";
      switch (error.code) {
        case 'invalid-email':
          _message = "이메일이 유효하지 않습니다";
          break;
        case '  user-disabled':
          _message = "해당 유저는 이용할 수 없습니다";
          break;
        case 'user-not-found':
          _message = "유저를 찾을수 없습니다";
          break;
        case 'wrong-password':
          _message = "패스워드가 틀렸습니다";
          break;
      }
      SnackBar snackBar = SnackBar(
        content: Text(_message),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });

    _firebaseUser = userCredential.user;
    if (_firebaseUser == null) {
      //로그인의 유무만 확인해주면 됨
      SnackBar snackBar =  SnackBar(
       content: Text("다시 시도해주세요"),
      );
      Scaffold.of(context).showSnackBar(snackBar);}
  }

  void signOut() async {
    changeFirebaseAuthStatus(FirebaseAuthStatus.progress); //loading화면 보여주
    _firebaseAuthStatus = FirebaseAuthStatus.signout;
    if (_firebaseUser != null) {
      _firebaseUser = null;
      if (await _facebookLogin!.isLoggedIn) //facebook로그인이 되어있는지 안되어있는지 확인하는것
          {
        await _facebookLogin!.logOut(); //facebook로그인이 되어있으면 로그아웃해줌
      await _firebaseAuth.signOut(); //firebaseauth를 signout해줌

      }
    }
    notifyListeners(); //signout했음을 다른 곳에도 알려줌
  }

  void changeFirebaseAuthStatus([FirebaseAuthStatus? firebaseAuthStatus]) {
    //[]를 이용해서 필수적으로 firebaseAuthStatus를 받아오지 않게 함
    if (firebaseAuthStatus != null) {
      _firebaseAuthStatus = firebaseAuthStatus;
    } else {
      //여기서부터 실행, firebaseAuthStatus를 받지 않아 null이기 때문
      if (_firebaseUser != null) {
        _firebaseAuthStatus = FirebaseAuthStatus.signin;
      } else {
        _firebaseAuthStatus = FirebaseAuthStatus.signout;
      }
    }

    notifyListeners(); //상태변화했으니 이를 알려줌
  }

  void loginWithFacebook(BuildContext context) async {
    changeFirebaseAuthStatus(
        FirebaseAuthStatus.progress); //myprogressindicator가 실행됨(loading화면)

    if (_facebookLogin == null) _facebookLogin = FacebookLogin();
    final result = await _facebookLogin!.logIn(['email']); //future값이기 때문

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        _handleFacebookTokenWithFirebase(context, result.accessToken.token);
        break;
      case FacebookLoginStatus.cancelledByUser:
        simpleSnackbar(context, 'User cancel facebook sign in');
        // TODO: Handle this case.
        break;
      case FacebookLoginStatus.error:
        simpleSnackbar(context, 'Error while facebook sign in');
        _facebookLogin!.logOut();
        break;
    }
  }

  void _handleFacebookTokenWithFirebase(
      BuildContext context, String token) //token을 사용해서 파이어베이스로 로그인하기
  async {
    final AuthCredential credential =
        FacebookAuthProvider.credential(token); //authcredential 외우기
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    _firebaseUser = userCredential.user;
    if (_firebaseUser == null) {
      simpleSnackbar(context, 'Error while facebook sign in');
    } else {
      await userNetworkRepository.attemptCreateUser(
          userKey: _firebaseUser!.uid,
          email: _firebaseUser!
              .email); //firestore로 데이터 보내주기, uid는 uique하기 때문에 userKey로 사용가능

    }
    notifyListeners();
  }

  FirebaseAuthStatus get firebaseAuthStatus =>
      _firebaseAuthStatus; //앞에 _가 있으면 다른 곳에서는 사용하지 못함

  User? get firebaseUser => _firebaseUser;
}

enum FirebaseAuthStatus {
  signout,
  progress,
  signin //로그인안한상태, 로그인중상태, 로그인상태
}
