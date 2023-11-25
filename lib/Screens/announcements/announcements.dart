import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../helpers.dart';
import '../createAssignment/controller.dart';

class Announcement extends StatefulWidget {
  final int classId;
  const Announcement({Key? key, required this.classId}) : super(key: key);

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  bool isLoading = false;
  final TextEditingController announcement = TextEditingController();
  final TextEditingController _controller = TextEditingController();

  List<PlatformFile> attachments = [];

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
        attachments = result.files;
      });
    } else {}
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
        actions: <Widget>[
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                List attachmentUrls = attachments.isNotEmpty
                    ? await uploadFilesToFirebaseStorage(attachments)
                    : [];
                String attachmentUrlsJson = attachmentUrls.toString();
                final params = {
                  "TeacherId": FirebaseAuth.instance.currentUser?.uid,
                  "ClassId": widget.classId,
                  "Description": announcement.text.trim(),
                  "AttachmentURLs": attachmentUrlsJson,
                };
                callLambdaFunction2(dotenv.env["POST_ANNOUNCEMENT"]!, params)
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
                      message: 'You have successfully posted Announcement',
                      contentType: ContentType.success,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                });
              },
              child: Text(
                "Post",
                style: Style().description(context, Colors.white),
              )),
          horizontalGap(context, 0.04),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
                visible: isLoading, child: const LinearProgressIndicator()),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: announcement,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Share to your class',
                      prefixIcon: Icon(Icons.post_add),
                    ),
                  ),
                  verticalGap(context, 0.01),
                  TextFormField(
                    controller: _controller,
                    readOnly: true,
                    onTap: pickFiles,
                    decoration: const InputDecoration(
                      labelText: 'Add attachment',
                      prefixIcon: Icon(Icons.attach_file),
                    ),
                  ),
                  verticalGap(context, 0.01),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
