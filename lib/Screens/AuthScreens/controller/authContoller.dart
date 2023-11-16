import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

GlobalKey<FormState> _userLoginFormKey = GlobalKey();
var _user;
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future signInWithGoogle() async {
  GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
  GoogleSignInAuthentication? googleSignInAuthentication =
      await googleSignInAccount?.authentication;
  AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication?.accessToken,
    idToken: googleSignInAuthentication?.idToken,
  );
  final authResult = await _auth.signInWithCredential(credential);
  _user = authResult.user;
  assert(!_user.isAnonymous);
  assert(await _user.getIdToken() != null);
  final currentUser = _auth.currentUser!;
  assert(_user.uid == currentUser.uid);
  debugPrint("User Name: ${_user.displayName}");
  debugPrint("User Email ${_user.email}");
}
