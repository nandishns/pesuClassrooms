import 'package:flutter/material.dart';
import 'package:pesuclassrooms/helpers.dart';

import '../modal/model.dart';

class ClassDetails extends StatefulWidget {
  final String className;
  final String teacherId;
  final String section;
  final String subject;
  const ClassDetails(
      {Key? key,
      required this.className,
      required this.teacherId,
      required this.section,
      required this.subject})
      : super(key: key);

  @override
  State<ClassDetails> createState() => _ClassDetailsState();
}

class _ClassDetailsState extends State<ClassDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                // Example class details
                var classDetails = ClassDetail(
                  name: 'Mathematics 101',
                  description: 'Introductory course to Mathematics',
                  teacherId: 'T123',
                  classCode: 'MATH101',
                  section: 'A',
                );

                showClassDetailsPopup(context, classDetails);
              },
              icon: Icon(
                Icons.info_outline,
                size: responsiveSize(30, context),
              ))
        ],
      ),
    );
  }
}

void showClassDetailsPopup(BuildContext context, ClassDetail classDetails) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(classDetails.name),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Description: ${classDetails.description}'),
              Text('Teacher ID: ${classDetails.teacherId}'),
              Text('Class Code: ${classDetails.classCode}'),
              Text('Section: ${classDetails.section}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
