import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pesuclassrooms/Screens/createAssignment/Correction.dart';
import 'package:pesuclassrooms/Screens/createAssignment/studentViewAssignment.dart';

import '../../helpers.dart';
import 'controller.dart';

class TeacherView extends StatefulWidget {
  final int assignmentId;
  final int classId;
  const TeacherView(
      {Key? key, required this.assignmentId, required this.classId})
      : super(key: key);

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Instructions'),
            Tab(text: 'Student Work'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InstructionsTabContent(
            assignmentId: widget.assignmentId,
          ), // Replace with your custom widget for instructors
          StudentWorkTabContent(
            assignmentId: widget.assignmentId,
            classId: widget.classId,
          ), // Replace with your custom widget for student work
        ],
      ),
    );
  }
}

class InstructionsTabContent extends StatefulWidget {
  final int assignmentId;
  const InstructionsTabContent({
    super.key,
    required this.assignmentId,
  });

  @override
  State<InstructionsTabContent> createState() => _InstructionsTabContentState();
}

class _InstructionsTabContentState extends State<InstructionsTabContent> {
  late bool isLoading = false;
  final StreamController _assignViewController = StreamController.broadcast();
  final StreamController _fetchAllSubmissions = StreamController.broadcast();
  @override
  void initState() {
    super.initState();
    fetchAssignmentDetails();
  }

  Future fetchAssignmentDetails() async {
    setState(() {
      isLoading = true;
    });
    final params1 = {
      "UserId": FirebaseAuth.instance.currentUser?.uid,
      "AssignmentId": widget.assignmentId
    };

    await callLambdaFunction2(
            dotenv.env["FETCH_ASSIGNMENT_DETAILS_STUDENT"]!, params1)
        .then((value) {
      _assignViewController.add(value);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Visibility(
              visible: isLoading, child: const LinearProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: StreamBuilder(
              stream: _assignViewController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No records found');
                }

                final assignment = snapshot.data!;

                var maxMarks =
                    assignment != null ? (assignment["MaxMarks"] ?? 0) : 0;
                bool acceptLate = assignment != null
                    ? (assignment["AcceptLateSub"] == 1)
                    : false;
                var reduceMarks =
                    assignment != null ? (assignment["reduceMarks"] ?? 0) : 0;

                var attachmentData = assignment != null
                    ? assignment["AssignmentAttachmentURL"]
                    : null;
                final attachment = attachmentData is List ? attachmentData : [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Grading Details :",
                        style: TextStyle(
                            fontSize: responsiveSize(24, context),
                            fontWeight: FontWeight.w600)),
                    verticalGap(context, 0.02),
                    Text("Max. Marks $maxMarks",
                        style: TextStyle(
                            fontSize: responsiveSize(20, context),
                            fontWeight: FontWeight.w500)),
                    verticalGap(context, 0.01),
                    acceptLate
                        ? Text("Late Submission deduction marks $reduceMarks")
                        : Container(),
                    verticalGap(context, 0.01),
                    Text(
                        "* Late Submissions are ${acceptLate ? "accepted" : "not accepted"}",
                        style: TextStyle(
                            fontSize: responsiveSize(20, context),
                            fontWeight: FontWeight.w500)),
                    verticalGap(context, 0.01),
                    attachment.isEmpty
                        ? const Text("No Attachments Available")
                        : AttachmentsList(attachments: attachment),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class StudentWorkTabContent extends StatefulWidget {
  final int classId;
  final int assignmentId;
  const StudentWorkTabContent(
      {super.key, required this.assignmentId, required this.classId});

  @override
  State<StudentWorkTabContent> createState() => _StudentWorkTabContentState();
}

class _StudentWorkTabContentState extends State<StudentWorkTabContent> {
  bool isLoading = false;
  final StreamController _fetchAllSubmissions = StreamController();
  @override
  void initState() {
    super.initState();
    fetchSubmissionDetails();
  }

  @override
  void dispose() {
    _fetchAllSubmissions.close();
    super.dispose();
  }

  Future fetchSubmissionDetails() async {
    setState(() {
      isLoading = true;
    });
    final params = {
      "AssignmentId": widget.assignmentId,
      "ClassId": widget.classId
    };

    await callLambdaFunction2(dotenv.env["FETCH_SUBMISSION"]!, params)
        .then((value) {
      _fetchAllSubmissions.add(value);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Visibility(
              visible: isLoading, child: const LinearProgressIndicator()),
          StreamBuilder(
            stream: _fetchAllSubmissions.stream,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Show loading indicator
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No records found');
              }

              final List snapshots = snapshot.data!;
              var firstElement = snapshots.first;

              List submissions = [];
              if (snapshots.length > 1) {
                submissions = snapshots.sublist(1) ?? [];
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${firstElement["SubmittedCount"]}",
                              style: TextStyle(
                                  fontSize: responsiveSize(34, context),
                                  fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              "Submitted Count",
                            )
                          ],
                        ),
                        Container(
                          height: 50,
                          width: 1,
                          color: Colors.black,
                          margin: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Column(
                          children: [
                            Text(
                              "${firstElement["NotSubmittedCount"] < 0 ? 0 : firstElement["NotSubmittedCount"]}",
                              style: TextStyle(
                                  fontSize: responsiveSize(34, context),
                                  fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              "Not Submitted Count",
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      var submission = submissions[index];
                      var studentName = submission['StudentName'];
                      var photoURL = submission['PhotoURL'];
                      var submissionId = submission['SubmissionId'];
                      var submissionDate = submission['SubmissionDate'];
                      var submissionStatus = submission['SubmissionStatus'];
                      var submissionAttachmentURL =
                          submission["SubmissionAttachmentURL"];
                      var grade = submission["Grade"] ?? 0;
                      var remarks = submission["Remarks"];
                      var hasTeacherCorrected =
                          submission["HasTeacherCorrected"];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.assignment,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: Correction(
                                    submissionAttachmentURL:
                                        submissionAttachmentURL,
                                    name: studentName,
                                    grade: grade,
                                    remark: remarks,
                                    hasTeacherCorrected: hasTeacherCorrected,
                                    submissionId: submissionId,
                                  ),
                                  type: PageTransitionType.rightToLeft));
                        },
                        title: Text(
                          "$studentName",
                          style:
                              TextStyle(fontSize: responsiveSize(18, context)),
                        ),
                        subtitle: Text(
                          "Submitted on $submissionDate",
                          style: TextStyle(
                              fontSize: responsiveSize(16, context),
                              color: Colors.grey),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                submissionStatus == "Submitted"
                                    ? Colors.green.shade200
                                    : Colors.orange.shade200),
                          ),
                          child: Text(
                            hasTeacherCorrected == 1
                                ? "Graded"
                                : submissionStatus,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
