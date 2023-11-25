import 'package:flutter/material.dart';
import 'package:pesuclassrooms/Screens/createAssignment/adminViewAssignment.dart';
import 'package:pesuclassrooms/Screens/createAssignment/studentViewAssignment.dart';

class AssignmentDetails extends StatefulWidget {
  final dueDate;
  final desc;
  final title;
  final isAdmin;
  final int assignmentId;
  final String submissionStatus;
  final int classId;
  const AssignmentDetails(
      {Key? key,
      required this.dueDate,
      required this.desc,
      required this.title,
      required this.isAdmin,
      required this.assignmentId,
      required this.submissionStatus,
      required this.classId})
      : super(key: key);

  @override
  State<AssignmentDetails> createState() => _AssignmentDetailsState();
}

class _AssignmentDetailsState extends State<AssignmentDetails> {
  @override
  Widget build(BuildContext context) {
    return widget.isAdmin
        ? TeacherView(
            assignmentId: widget.assignmentId,
            classId: widget.classId,
          )
        : StudentViewAssignment(
            dueDate: widget.dueDate,
            desc: widget.desc,
            title: widget.title,
            assignmentId: widget.assignmentId,
            submissionStatus: widget.submissionStatus);
  }
}
