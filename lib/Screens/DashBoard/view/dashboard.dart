import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pesuclassrooms/helpers.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final userName = FirebaseAuth.instance.currentUser?.displayName?.split("")[0];

  @override
  Widget build(BuildContext context) {
    final profile = FirebaseAuth.instance.currentUser?.photoURL ?? "$userName";
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "PESU Classroom",
          style: TextStyle(
              fontSize: responsiveSize(26, context),
              fontWeight: FontWeight.w500),
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
    );
  }
}
