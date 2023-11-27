import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesuclassrooms/utils/assignmentTile.dart';

import '../../../helpers.dart';
import '../../createAssignment/controller.dart';

class ClassWork extends StatefulWidget {
  final int classId;
  final bool isAdmin;
  const ClassWork({Key? key, required this.classId, required this.isAdmin})
      : super(key: key);

  @override
  State<ClassWork> createState() => _ClassWorkState();
}

class _ClassWorkState extends State<ClassWork> {
  final StreamController<List<dynamic>> _assignmentsController =
      StreamController();
  bool isLoading = false;
  @override
  void initState() {
    fetchAssignments(widget.classId);
    super.initState();
  }

  Future fetchAssignments(classId) async {
    setState(() {
      isLoading = true;
    });
    final params = {
      "ClassId": classId,
      "UserId": FirebaseAuth.instance.currentUser?.uid
    };
    await callLambdaFunction2(dotenv.env["FETCH_ASSIGNMENT"]!, params)
        .then((value) {
      _assignmentsController.add(value);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RefreshIndicator(
        onRefresh: () => fetchAssignments(widget.classId),
        child: Column(children: [
          Visibility(
              visible: isLoading, child: const LinearProgressIndicator()),
          StreamBuilder(
            stream: _assignmentsController
                .stream, // Replace with your class instance
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No Assignments found');
              }

              List assignments = snapshot.data!;

              return SizedBox(
                height: responsiveSize(1000, context),
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    var title = assignments[index]["Title"];
                    var dueDate = assignments[index]["DueDate"];
                    var assignmentId = assignments[index]["AssignmentId"];
                    var desc = assignments[index]["Description"];
                    var submissionStatus = assignments[index]
                                ["SubmissionStatus"] ==
                            "Submission Due"
                        ? "Due"
                        : assignments[index]["SubmissionStatus"];

                    return assignmentTile(
                        "$title",
                        "$dueDate",
                        desc,
                        assignmentId,
                        submissionStatus,
                        widget.isAdmin,
                        widget.classId,
                        context);
                  },
                ),
              );
            },
          )
        ]),
      ),
    );
  }
}
