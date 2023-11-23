import 'dart:async';

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
  @override
  void initState() {
    fetchAssignments(widget.classId);
    super.initState();
  }

  Future fetchAssignments(classId) async {
    final params = {"ClassId": classId};
    await callLambdaFunction2(dotenv.env["FETCH_ASSIGNMENT"]!, params)
        .then((value) {
      print(value);
      _assignmentsController.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => fetchAssignments(widget.classId),
      child: SingleChildScrollView(
        child: Column(children: [
          StreamBuilder(
            stream: _assignmentsController
                .stream, // Replace with your class instance
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show loading indicator
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No members found');
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
                    var reduceMarks = assignments[index]["ReduceMarks"];
                    var attachments = assignments[index]["AttachmentURLs"];
                    var maxMarks =
                        int.parse(assignments[index]["MaxMarks"].toString());

                    return assignmentTile(
                        "$title",
                        "$dueDate",
                        maxMarks,
                        desc,
                        attachments,
                        reduceMarks,
                        assignmentId,
                        widget.isAdmin,
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
