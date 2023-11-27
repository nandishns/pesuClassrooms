import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesuclassrooms/Screens/createAssignment/studentViewAssignment.dart';

import '../../helpers.dart';
import 'controller.dart';

class Correction extends StatefulWidget {
  final int submissionId;
  final List submissionAttachmentURL;
  final String name;
  final grade;
  final remark;
  final int hasTeacherCorrected;
  const Correction(
      {Key? key,
      required this.submissionAttachmentURL,
      required this.name,
      required this.grade,
      required this.remark,
      required this.hasTeacherCorrected,
      required this.submissionId})
      : super(key: key);

  @override
  State<Correction> createState() => _CorrectionState();
}

class _CorrectionState extends State<Correction> {
  late TextEditingController grade = TextEditingController();
  late TextEditingController remarks = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: Colors.black,
            size: responsiveSize(30, context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Visibility(
              visible: isLoading,
              child: const LinearProgressIndicator(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              onTap: () {},
              title: Text(
                "${widget.name}",
                style: TextStyle(fontSize: responsiveSize(18, context)),
              ),
              subtitle: Text(
                "Submitted",
                style: TextStyle(
                    fontSize: responsiveSize(16, context), color: Colors.grey),
              ),
            ),
            verticalGap(context, 0.02),
            widget.submissionAttachmentURL == null ||
                    widget.submissionAttachmentURL.isEmpty
                ? const Text("No submissionAttachment Available")
                : AttachmentsList(attachments: widget.submissionAttachmentURL),
            verticalGap(context, 0.04),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.hasTeacherCorrected == 1
                      ? TextFormField(
                          controller: grade,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: '${widget.grade}',
                          ),
                        )
                      : TextFormField(
                          controller: grade,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              labelText: 'Enter the Grade'),
                        ),
                  verticalGap(context, 0.02),
                  widget.hasTeacherCorrected == 1
                      ? TextFormField(
                          controller: remarks,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: '${widget.remark}',
                          ),
                        )
                      : TextFormField(
                          controller: remarks,
                          decoration: const InputDecoration(
                              labelText: 'Enter the remarks'),
                        ),
                  verticalGap(context, 0.03),
                  Center(
                    child: SizedBox(
                      height: responsiveSize(60, context),
                      width: responsiveSize(500, context),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blueAccent),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            final params = {
                              "Grade": widget.hasTeacherCorrected == 1
                                  ? widget.grade
                                  : grade.text,
                              "SubmissionId": widget.submissionId,
                              "Remarks": widget.hasTeacherCorrected == 1
                                  ? widget.remark
                                  : remarks.text,
                            };
                            await callLambdaFunction2(
                                    dotenv.env["CORRECTION"]!, params)
                                .then((value) {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pop(context);
                              Navigator.pop(context);
                              final snackBar = SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                content: AwesomeSnackbarContent(
                                  title: 'Success!',
                                  message:
                                      'You have successfully Graded Assignment',
                                  contentType: ContentType.success,
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(snackBar);
                            });
                          },
                          child: Text(
                            "Mark Corrected",
                            style: Style().description(context, Colors.white),
                          )),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
