import 'package:Shrine/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signin.dart';
import 'home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
User signedUser;
String isSigned;

Future<void> signInWithGoogle() async {
  await Firebase.initializeApp();

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded: ' + user.uid);
    signedUser = user;
  }
}

Future<void> _getUser() async {
  final get = await FirebaseFirestore.instance.collection('users').doc(signedUser.uid).get();
  if(get.data() == null) {
    isSigned = "No";
  }
  else {
    isSigned = "Yes";
  }
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  print("User Signed Out");
}


class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final String imgPath = "images/title.jpg";
    final String imgPath2 = "images/cart.jpg";
    final StorageReference pathReference = storageRef.child(imgPath);
    final StorageReference pathReference2 = storageRef.child(imgPath2);

    return FutureBuilder(
      future: pathReference.getDownloadURL(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 60.0),
              children: <Widget>[
                SizedBox(height: 90.0),
                Column(
                  children: <Widget>[
                    FutureBuilder(
                      future: pathReference2.getDownloadURL(),
                      builder: (context, snapshot) {
                        return Image(
                          image: NetworkImage(snapshot.data.toString(),),
                          width: 150,
                          height: 150,
                        );
                      },
                    ),
                    SizedBox(height: 16.0),
                    //Text('한동 같이사', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, fontFamily: 'NotoSans',),),
                    Image(
                      image: NetworkImage(snapshot.data.toString()),
                    ),
                  ],
                ),
                SizedBox(height: 140.0),
                SizedBox(
                  child: FlatButton(
                    padding: EdgeInsets.all(5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0,),
                      side: BorderSide(color: Color.fromRGBO(93, 176, 117, 1), width: 4,),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            child: Text(
                              "Google로 로그인",
                              style: TextStyle(color: Color.fromRGBO(93, 176, 117, 1), fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      signInWithGoogle().then((result) {

                        _getUser().then((result) {
                          if(isSigned == "Yes") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  HomePage()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  SignInPage()),
                            );
                          }
                        });
                      });
                    },
                  ),
                ),
                SizedBox(height: 12.0),
              ],
            ),
          ),
        );
      },
    );

  /*
    return
    */
  }
}
