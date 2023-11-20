import 'package:flutter/material.dart';
import 'package:pesuclassrooms/helpers.dart';

import '../modal/model.dart';

class ClassDetails extends StatefulWidget {
  final ClassDetail classDetails;

  const ClassDetails({
    Key? key,
    required this.classDetails,
  }) : super(key: key);

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
                showClassDetailsPopup(context, widget.classDetails);
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
              Text('Section: ${classDetails.section}'),
              Text('SEM: ${classDetails.sem}'),
              Text('Class Code: ${classDetails.classCode}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
