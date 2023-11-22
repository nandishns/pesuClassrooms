import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesuclassrooms/helpers.dart';

Future createAssignment(classId, assignmentName, desc, dueDate, maxMarks,
    deductMarks, context) async {
  final params = {
    "Title": assignmentName,
    "Description": desc,
    "DueDate": dueDate,
  };

  callLambdaFunction(dotenv.env["CREATE_ASSIGNMENT"], params).then((value) {});
}
