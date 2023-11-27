import 'dart:convert';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<void> createAssignment(
    maxMarks,
    int classId,
    String assignmentName,
    String desc,
    String dueDate,
    bool acceptLateSub,
    int reduceMarks,
    attachments,
    BuildContext context) async {
  // print(attachments);
  final Map<String, dynamic> params = {
    "ClassId": classId,
    "MaxMarks": int.parse(maxMarks),
    "Title": assignmentName,
    "Description": desc,
    "DueDate": dueDate,
    "AcceptLateSub": acceptLateSub.toString(),
    "ReduceMarks": reduceMarks,
    "AttachmentURLs": attachments
  };

  try {
    await callLambdaFunction2(dotenv.env['CREATE_ASSIGNMENT']!, params)
        .then((value) {
      Navigator.pop(context);
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success!',
          message: 'You have successfully created Assignment',
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      debugPrint('Assignment created: ');
    });
  } catch (e) {
    print('Error creating assignment: $e');
  }
}

Future<List<String>> uploadFilesToFirebaseStorage(
    List<PlatformFile> files) async {
  final List<String> attachmentUrls = [];

  try {
    for (var file in files) {
      Uint8List? fileData = file.bytes;

      // If bytes are null, try reading the file from the path
      if (fileData == null && file.path != null) {
        final fileOnDevice = File(file.path!);
        fileData = await fileOnDevice.readAsBytes();
      }

      if (fileData != null) {
        final fileName =
            '${FirebaseAuth.instance.currentUser?.uid}/${file.name}';
        final Reference storageReference =
            FirebaseStorage.instance.ref().child(fileName);
        final UploadTask uploadTask = storageReference.putData(fileData);

        await uploadTask.whenComplete(() async {
          final downloadURL = await storageReference.getDownloadURL();
          attachmentUrls.add(downloadURL);
        });
      } else {
        print('Unable to read file bytes for ${file.name}');
        // Handle the case where file bytes could not be read
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading files: $e');
    }
  }

  return attachmentUrls;
}

Future callLambdaFunction2(
    String apiEndpoint, Map<String, dynamic> requestData) async {
  try {
    final Map<String, String> stringParams = requestData.map((key, value) {
      return MapEntry(key, value.toString());
    });

    var query = Uri(queryParameters: stringParams).query;
    var url = Uri.parse('$apiEndpoint?$query'.trim());

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      debugPrint("*************LAMBDA-SUCCESS************");
      return json.decode(response.body);
    } else {
      debugPrint(response.body);
      debugPrint("*************LAMBDA-FAILED************");
      return null; // Or handle error appropriately
    }
  } catch (e) {
    debugPrint("*************LAMBDA-ERROR************: $e");
    throw Exception("Error calling Lambda function: $e");
  }
}
