import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../helpers.dart';

Future joinClass(
  classCode,
  context,
) async {
  try {
    final params = {
      "ClassCode": classCode,
      "UserId": FirebaseAuth.instance.currentUser?.uid,
    };
    await callLambdaFunction(dotenv.env["JOIN_CLASS"], params).then((value) {
      Navigator.pop(context);
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success!',
          message: 'You have successfully joined class',
          contentType: ContentType.help,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    });
  } catch (e) {
    throw Exception("$e");
  }
}
