import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';

import '../../../helpers.dart';
import '../../classSection/modal/model.dart';
import '../../classSection/view/classDetails.dart';

Future createClass(
    formKey, className, description, section, sem, context, bgUrl) async {
  try {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final classDetails = {
        "className": className,
        "description": description,
        "teacherId": FirebaseAuth.instance.currentUser?.uid,
        "section": section,
        "sem": sem.toString(),
        "bgUrl": bgUrl
      };
      await callLambdaFunction(dotenv.env["CREATE_CLASS"], classDetails)
          .then((value) {
        final int classId;
        final String classCode;
        classId = value["classId"];
        classCode = value["classCode"];
        var classDetails = ClassDetail(
            name: className,
            description: description,
            teacherId: FirebaseAuth.instance.currentUser!.uid,
            classCode: classCode,
            section: section,
            classId: classId,
            sem: sem,
            teacherName: "",
            bgUrl: bgUrl);
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: ClassDetails(
                  classDetails: classDetails,
                ),
                type: PageTransitionType.leftToRight));
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: 'You have successfully created ${classDetails.name} class',
            contentType: ContentType.help,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      });
    }
  } catch (e) {
    throw Exception("$e");
  }
}
