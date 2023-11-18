import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesuclassrooms/helpers.dart';

Future createClass(formKey, className, description, section, context) async {
  try {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final classDetails = {
        "className": className,
        "description": description,
        "teacherId": FirebaseAuth.instance.currentUser?.uid,
        "section": section
      };
      await callLambdaFunction(dotenv.env["CREATE_CLASS"], classDetails);
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success!',
          message: 'You have successfully created $className class',
          contentType: ContentType.help,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  } catch (e) {
    throw Exception("$e");
  }
}
