import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pesuclassrooms/Screens/AuthScreens/controller/authContoller.dart';
import 'package:pesuclassrooms/helpers.dart';

import '../../AuthScreens/view/googleAuthScreen.dart';
import '../../createClass/view/createClass.dart';
import '../../joinClass/joinClass.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final userName = FirebaseAuth.instance.currentUser?.displayName?.split("")[0];
  final StreamController<List<dynamic>> _classesController = StreamController();
  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.width;
    final profile = FirebaseAuth.instance.currentUser?.photoURL ?? "$userName";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "PESU Classroom",
          style: TextStyle(
            fontSize: responsiveSize(26, context),
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 1,
        leading: const DrawerButton(),
        actions: [
          CircleAvatar(
            radius: responsiveSize(22, context),
            backgroundColor: profile.length == 1
                ? Colors.blueGrey.withOpacity(0.7)
                : Colors.transparent,
            child: profile.length == 1
                ? Text(
                    "$userName",
                    style: Style().description(context, Colors.white),
                  )
                : CachedNetworkImage(
                    imageUrl: profile,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
          ),
          horizontalGap(context, 0.01),

          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/deadline.png",
                      width: responsiveSize(30, context),
                    ),
                    horizontalGap(context, 0.01),
                    Text(
                      "View Deadlines",
                      style: Style().description(context, Colors.black),
                    ),
                  ],
                ),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              //TODO: implement view deadlines
            }
          }),
          // const Icon(Icons.more_vert)
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Container(
          margin: kIsWeb // Check if it's web
              ? EdgeInsets.zero // No margin for web
              : EdgeInsets.only(
                  right: width * 0.1,
                  left: width * 0.05,
                  top: responsiveSize(
                      20, context)), // Margin for other platforms
          child: ListView(
            padding: EdgeInsets.only(top: height * 0.08),
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1.0, color: Color(0xFFEEEAEA))),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.person_outline, color: Colors.black),
                      SizedBox(width: width * 0.06),
                      const Expanded(
                        // Wrap Text with Expanded to prevent overflow
                        child: Text(
                          'Profile',
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1.0, color: Color(0xEEEAEAFF))),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      const Icon(Icons.feed_outlined, color: Colors.black),
                      SizedBox(
                        width: width * 0.06,
                      ),
                      Text('Feedback'),
                    ],
                  ),
                  onTap: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>FeedbackScreen()));
                  },
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1.0, color: Color(0xEEEAEAFF))),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.black),
                      SizedBox(
                        width: width * 0.06,
                      ),
                      Text('Logout'),
                    ],
                  ),
                  onTap: () async {
                    FirebaseAuth.instance.signOut().then((value) async {
                      await signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoogleAuthScreen()));
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: responsiveSize(40, context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchClasses,
        color: Colors.black,
        child: StreamBuilder(
          stream: _classesController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No classes found'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var classData = snapshot.data![index];
                return ClassCard(
                    className: classData["ClassName"],
                    teacherName: classData["TeacherName"] ?? "",
                    classTime: classData["CreationDate"],
                    section: classData["Section"],
                    classId: classData["ClassId"],
                    teacherId: classData["TeacherId"],
                    sem: classData["Sem"],
                    description: classData["Description"],
                    classCode: classData["ClassCode"],
                    bgUrl: classData["bgUrl"]);
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _fetchClasses() async {
    try {
      await callLambdaFunction(dotenv.env["FETCH_CLASS_DETAILS"],
          {"UserId": FirebaseAuth.instance.currentUser?.uid}).then((value) {
        _classesController.add(value);
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    builder: (BuildContext bc) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                size: responsiveSize(30, context),
              ),
              title: Text(
                'Create a Class',
                style: Style().description(context, Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageTransition(
                      child: const CreateClass(),
                      type: PageTransitionType.rightToLeft,
                    ));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.group_add,
                size: responsiveSize(30, context),
              ),
              title: Text(
                'Join a Class',
                style: Style().description(context, Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageTransition(
                      child: const JoinClass(),
                      type: PageTransitionType.rightToLeft,
                    ));
              },
            ),
          ],
        ),
      );
    },
  );
}
