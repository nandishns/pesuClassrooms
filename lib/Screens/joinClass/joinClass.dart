import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pesuclassrooms/Screens/joinClass/controller.dart';

import '../../helpers.dart';

class JoinClass extends StatefulWidget {
  const JoinClass({Key? key}) : super(key: key);

  @override
  State<JoinClass> createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  bool isLoading = false;
  String? _classCode;

  TextEditingController classCode = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Join class",
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: Colors.black,
            size: responsiveSize(30, context),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              onPressed: () {
                if (classCode.text == "") {
                  final snackBar = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Alert!',
                      contentType: ContentType.failure,
                      message: 'Please Enter Class Code!',
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                  return;
                }
                setState(() {
                  isLoading = true;
                });

                joinClass(
                  classCode.text,
                  context,
                ).then((value) {
                  setState(() {
                    isLoading = false;
                  });
                });
              },
              child: Text(
                "Join Class",
                style: Style().description(context, Colors.white),
              )),
          horizontalGap(context, 0.04),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: isLoading,
                child: const LinearProgressIndicator(
                  color: Colors.blueAccent,
                ),
              ),
              verticalGap(context, 0.01),
              Text(
                "You're currently signed in as",
                style: TextStyle(
                  fontSize: responsiveSize(18, context),
                ),
              ),
              ListTile(
                leading: CachedNetworkImage(
                  imageUrl: FirebaseAuth.instance.currentUser?.photoURL ?? "",
                  imageBuilder: (context, imageProvider) => Container(
                    width: responsiveSize(50, context),
                    height: responsiveSize(50, context),
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
                title: Text(
                  "${FirebaseAuth.instance.currentUser?.displayName}",
                  style: TextStyle(fontSize: responsiveSize(17, context)),
                ),
                subtitle: Text("${FirebaseAuth.instance.currentUser?.email}"),
              ),
              const Divider(),
              verticalGap(context, 0.01),
              Text(
                "Ask your teacher for the class code, then enter it here",
                style: TextStyle(
                  fontSize: responsiveSize(18, context),
                ),
              ),
              verticalGap(context, 0.02),
              TextFormField(
                controller: classCode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Class Code',
                ),
                onSaved: (value) => _classCode = value ?? '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter class name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
