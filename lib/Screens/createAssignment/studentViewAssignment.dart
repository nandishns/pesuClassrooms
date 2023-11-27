import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pesuclassrooms/Screens/createAssignment/controller.dart';
import 'package:pesuclassrooms/helpers.dart';

class StudentViewAssignment extends StatefulWidget {
  final String dueDate;
  final String desc;
  final String title;
  final int assignmentId;
  final String submissionStatus;

  const StudentViewAssignment(
      {Key? key,
      required this.dueDate,
      required this.desc,
      required this.title,
      required this.assignmentId,
      required this.submissionStatus})
      : super(key: key);

  @override
  State<StudentViewAssignment> createState() => _StudentViewAssignmentState();
}

class _StudentViewAssignmentState extends State<StudentViewAssignment> {
  final StreamController _assignViewController = StreamController();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController submissionTexT = TextEditingController();
  late bool isLoading = false;
  late List<PlatformFile> submission;
  @override
  void initState() {
    fetchAssignmentDetails();
    submission = [];
    super.initState();
  }

  Future fetchAssignmentDetails() async {
    setState(() {
      isLoading = true;
    });
    final params = {
      "UserId": FirebaseAuth.instance.currentUser?.uid,
      "AssignmentId": widget.assignmentId
    };
    await callLambdaFunction2(
            dotenv.env["FETCH_ASSIGNMENT_DETAILS_STUDENT"]!, params)
        .then((value) {
      _assignViewController.add(value);
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ["pdf"],
    );

    if (result != null) {
      List<String> fileNames = result.files.map((file) => file.name).toList();
      setState(() {
        _controller.text = fileNames.join(', ');
        submission = result.files;
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
                visible: isLoading, child: const LinearProgressIndicator()),
            Padding(
              padding: EdgeInsets.only(
                  left: responsiveSize(10, context),
                  top: responsiveSize(16, context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: TextStyle(
                          fontSize: responsiveSize(24, context),
                          fontWeight: FontWeight.w600)),
                  verticalGap(context, 0.01),
                  Text(widget.desc,
                      style: TextStyle(
                        fontSize: responsiveSize(20, context),
                      )),
                  verticalGap(context, 0.01),
                  Text("Due on ${widget.dueDate}",
                      style: TextStyle(
                        fontSize: responsiveSize(18, context),
                      )),
                  verticalGap(context, 0.03),
                  StreamBuilder(
                    stream: _assignViewController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(); // Show loading indicator
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No records found');
                      }

                      final assignment = snapshot.data!;

                      var maxMarks = assignment != null
                          ? (assignment["MaxMarks"] ?? 0)
                          : 0;
                      bool acceptLate = assignment != null
                          ? (assignment["AcceptLateSub"] == 1)
                          : false;
                      var reduceMarks = assignment != null
                          ? (assignment["reduceMarks"] ?? 0)
                          : 0;
                      var submissionText = assignment != null
                          ? (assignment["SubmissionText"] ?? "")
                          : "";
                      var submissionDate = assignment != null
                          ? (assignment["SubmissionDate"] ?? "")
                          : "";
                      var grade =
                          assignment != null ? (assignment["Grade"] ?? 0) : 0;
                      var remarks =
                          assignment != null ? (assignment["Grade"] ?? 0) : 0;
                      var hasTeacherCorrected = assignment != null
                          ? (assignment["HasTeacherCorrected"] ?? 0)
                          : 0;

                      var submissionAttachmentData = assignment != null
                          ? assignment["SubmissionAttachmentURL"]
                          : null;
                      final submissionAttachment =
                          submissionAttachmentData is List
                              ? submissionAttachmentData
                              : [];

                      var attachmentData = assignment != null
                          ? assignment["AssignmentAttachmentURL"]
                          : null;
                      final attachment =
                          attachmentData is List ? attachmentData : [];
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
                              ? Text(
                                  "Late Submission deduction marks $reduceMarks")
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
                          verticalGap(
                              context,
                              widget.submissionStatus == "Submitted"
                                  ? 0.04
                                  : 0.24),
                          widget.submissionStatus == "Submitted"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Submission Details :",
                                        style: TextStyle(
                                            fontSize:
                                                responsiveSize(24, context),
                                            fontWeight: FontWeight.w600)),
                                    verticalGap(context, 0.02),
                                    Text("Submitted on : $submissionDate",
                                        style: TextStyle(
                                            fontSize:
                                                responsiveSize(20, context),
                                            fontWeight: FontWeight.w500)),
                                    verticalGap(context, 0.01),
                                    Text("Remarks : $submissionText",
                                        style: TextStyle(
                                            fontSize:
                                                responsiveSize(20, context),
                                            fontWeight: FontWeight.w500)),
                                    verticalGap(context, 0.01),
                                    submissionAttachment.isEmpty
                                        ? const Text(
                                            "No submissionAttachment Available")
                                        : AttachmentsList(
                                            attachments: submissionAttachment),
                                  ],
                                )
                              : submitContainer(context),
                          verticalGap(context, 0.03),
                          hasTeacherCorrected == 1
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Correction Details :",
                                        style: TextStyle(
                                            fontSize:
                                                responsiveSize(24, context),
                                            fontWeight: FontWeight.w600)),
                                    verticalGap(context, 0.02),
                                    Text("Grade : $grade",
                                        style: TextStyle(
                                            fontSize:
                                                responsiveSize(20, context),
                                            fontWeight: FontWeight.w500)),
                                    verticalGap(context, 0.01),
                                    Text("Remarks : $remarks",
                                        style: TextStyle(
                                            fontSize:
                                                responsiveSize(20, context),
                                            fontWeight: FontWeight.w500)),
                                  ],
                                )
                              : Container(),
                          verticalGap(context, 0.02),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget submitContainer(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          readOnly: true,
          onTap: pickFiles,
          decoration: const InputDecoration(
            labelText: 'Select File',
            suffixIcon: Icon(Icons.attach_file),
          ),
        ),
        verticalGap(context, 0.02),
        TextFormField(
          controller: submissionTexT,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        verticalGap(context, 0.03),
        Center(
          child: SizedBox(
            height: responsiveSize(60, context),
            width: responsiveSize(500, context),
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  if (submission.isEmpty) {
                    final snackbar = const SnackBar(
                      backgroundColor: Colors.black,
                      content: Text("Please attach a file"),
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackbar);

                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });
                  List<String> attachmentUrls =
                      await uploadFilesToFirebaseStorage(submission);
                  String attachmentUrlsJson = attachmentUrls.toString();
                  final params = {
                    "AssignmentId": widget.assignmentId,
                    "UserId": FirebaseAuth.instance.currentUser?.uid,
                    "SubmissionText": submissionTexT.text.trim(),
                    "SubmissionFileURL": attachmentUrlsJson,
                  };
                  await callLambdaFunction2(
                          dotenv.env["SUBMIT_ASSIGNMENT"]!, params)
                      .then((value) {
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context);

                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Success!',
                        message: 'You have successfully submitted Assignment',
                        contentType: ContentType.success,
                      ),
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar);
                  });
                },
                child: Text(
                  "Submit",
                  style: Style().description(context, Colors.white),
                )),
          ),
        ),
      ],
    );
  }
}

class AttachmentsList extends StatelessWidget {
  final List attachments;

  const AttachmentsList({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        String url = attachments[index];

        String fileName = url.split('/').last;

        return PdfAttachmentPreview(
          pdfUrl: url,
          fileName: fileName,
          index: index,
        );
      },
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final String filePath;

  PdfViewPage({required this.filePath});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: PDFView(filePath: widget.filePath),
    );
  }
}

class PdfAttachmentPreview extends StatelessWidget {
  final String pdfUrl;
  final String fileName;
  final int index;

  const PdfAttachmentPreview(
      {super.key,
      required this.pdfUrl,
      required this.fileName,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _downloadAndOpenPdf(context, pdfUrl);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.picture_as_pdf,
              size: 24,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text("Attachment ${index + 1}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _downloadAndOpenPdf(BuildContext context, pdfUrl) async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/$fileName";
      await dio.download(pdfUrl.toString().trim(), filePath);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PdfViewPage(filePath: filePath),
      ));
    } catch (e) {
      // Handle error
      print(e.toString());
    }
  }
}
