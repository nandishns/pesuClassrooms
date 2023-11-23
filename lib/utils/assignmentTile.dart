import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../Screens/createAssignment/assignmentDetails.dart';
import '../helpers.dart';

Widget assignmentTile(assignmentName, maxMarks, dueDate, desc, attachments,
    reduceMarks, assignmentId, isAdmin, context) {
  return ListTile(
    onTap: () {
      Navigator.push(
          context,
          PageTransition(
              child: AssignmentDetails(
                  maxMarks: maxMarks,
                  dueDate: dueDate,
                  desc: desc,
                  title: assignmentName,
                  attachment: attachments,
                  isAdmin: isAdmin),
              type: PageTransitionType.rightToLeft));
    },
    leading: const CircleAvatar(
      backgroundColor: Colors.blueAccent,
      child: Icon(
        Icons.assignment,
        color: Colors.white,
      ),
    ),
    title: Text(
      "$assignmentName",
      style: TextStyle(fontSize: responsiveSize(18, context)),
    ),
    subtitle: Text(
      "Due on $dueDate",
      style:
          TextStyle(fontSize: responsiveSize(16, context), color: Colors.grey),
    ),
    trailing: PopupMenuButton(itemBuilder: (context) {
      return [
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "Edit",
            style: Style().description(context, Colors.black),
          ),
        ),
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "Delete",
            style: Style().description(context, Colors.black),
          ),
        ),
      ];
    }, onSelected: (value) {
      if (value == 0) {
        //TODO: implement view deadlines
      }
    }),
  );
}
