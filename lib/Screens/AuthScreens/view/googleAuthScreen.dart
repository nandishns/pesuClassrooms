import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pesuclassrooms/helpers.dart';

import '../../DashBoard/view/dashboard.dart';
import '../controller/authContoller.dart';

class GoogleAuthScreen extends StatefulWidget {
  const GoogleAuthScreen({Key? key}) : super(key: key);

  @override
  State<GoogleAuthScreen> createState() => _GoogleAuthScreenState();
}

class _GoogleAuthScreenState extends State<GoogleAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            verticalGap(context, 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "PESU ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: responsiveSize(28, context),
                  ),
                ),
                Text(
                  "Classrooms",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: responsiveSize(28, context),
                      color: Colors.blueAccent),
                ),
              ],
            ),
            verticalGap(context, 0.02),
            Text(
              "😊 Let's get started",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: responsiveSize(40, context),
              ),
            ),
            verticalGap(context, 0.01),
            Text(
              "Sign up to classrooms and get started",
              textAlign: TextAlign.center,
              style: Style().description(context, Colors.black),
            ),
            verticalGap(context, 0.02),
            InkWell(
              child: Container(
                  width: responsiveSize(400, context),
                  height: responsiveSize(60, context),
                  margin: const EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // color: Colors.white.withOpacity(0.5),
                      border: Border.all(color: Colors.black)),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: responsiveSize(30, context),
                        width: responsiveSize(30, context),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/google.png'),
                              fit: BoxFit.cover),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                            fontSize: responsiveSize(22, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ))),
              onTap: () async {
                signInWithGoogle().then((user) {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: const DashBoard(),
                          type: PageTransitionType.rightToLeft));
                }).catchError((e) => debugPrint(e));
              },
            ),
            verticalGap(context, 0.03),
            SizedBox(
                width: responsiveSize(400, context), child: const Divider()),
            InkWell(
              child: Container(
                  width: responsiveSize(400, context),
                  height: responsiveSize(60, context),
                  margin: const EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // color: Colors.white.withOpacity(0.5),
                      border: Border.all(color: Colors.black)),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: responsiveSize(30, context),
                        width: responsiveSize(30, context),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/google.png'),
                              fit: BoxFit.cover),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        'Sign in with Apple',
                        style: TextStyle(
                            fontSize: responsiveSize(22, context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ))),
              onTap: () async {
                signInWithGoogle().then((user) {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: const DashBoard(),
                          type: PageTransitionType.rightToLeft));
                }).catchError((e) => debugPrint(e));
              },
            ),
          ],
        ),
      ),
    );
  }
}
