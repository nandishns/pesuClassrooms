import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:pesuclassrooms/helpers.dart';

var _user;
final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future signInWithGoogle() async {
  try {
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
    String? displayName = FirebaseAuth.instance.currentUser?.displayName;

    String? firstName;
    String? lastName;

    if (displayName != null && displayName.contains(" ")) {
      List<String> names = displayName.split(" ");
      firstName = names[0];

      lastName = names.length > 1 ? names.last : null;
    } else {
      firstName = displayName;
    }

    final userDetails = {
      "UserId": FirebaseAuth.instance.currentUser?.uid,
      "FirstName": firstName ?? "",
      "LastName": lastName ?? "",
      "Email": FirebaseAuth.instance.currentUser?.email,
      "JoiningDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "photoUrl": FirebaseAuth.instance.currentUser?.photoURL ?? ""
    };
    await callLambdaFunction(dotenv.env["SAVE_USER_DETAILS"]!, userDetails);
    debugPrint("User Name: ${_user.displayName}");
    debugPrint("User Email ${_user.email}");
  } catch (e) {
    throw Exception("Something went wrong $e");
  }
}

Future signOut() async {
  await _googleSignIn.signOut();
}
