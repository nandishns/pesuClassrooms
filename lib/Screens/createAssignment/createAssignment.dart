import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pesuclassrooms/Screens/createAssignment/controller.dart';

import '../../helpers.dart';

class CreateAssignment extends StatefulWidget {
  final int classId;
  const CreateAssignment({Key? key, required this.classId}) : super(key: key);

  @override
  State<CreateAssignment> createState() => _CreateAssignmentState();
}

class _CreateAssignmentState extends State<CreateAssignment> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? _className;
  String? _description;
  TextEditingController assignmentName = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController marks = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController deductMarks = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  var checkBoxValue = false;
  List<PlatformFile> attachments = [];
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      // Format the picked time and update the controller
      _timeController.text = pickedTime.format(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year - 5),
      lastDate: DateTime(initialDate.year + 5),
      helpText: 'Select a date',
    );

    if (pickedDate != null && pickedDate != initialDate) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
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
        attachments = result.files;
      });
    } else {}
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Assignment",
        ),
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
                DateTime selectedDate =
                    parseDateFromString(_dateController.text);
                TimeOfDay selectedTime =
                    parseTimeFromString(_timeController.text);

                DateTime combinedDateTime =
                    combineDateTimeWithTime(selectedDate, selectedTime);
                String dateTimeForSql = formatDateTimeForSql(combinedDateTime);
                List<String> attachmentUrls =
                    await uploadFilesToFirebaseStorage(attachments);
                String attachmentUrlsJson = attachmentUrls.toString();

                await createAssignment(
                        marks.text,
                        widget.classId,
                        assignmentName.text,
                        description.text,
                        dateTimeForSql,
                        checkBoxValue,
                        int.parse(deductMarks.text),
                        attachmentUrlsJson,
                        context)
                    .then((value) {
                  setState(() {
                    isLoading = false;
                  });
                });
              },
              child: Text(
                "Assign",
                style: Style().description(context, Colors.white),
              )),
          horizontalGap(context, 0.04),
        ],
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
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: assignmentName,
                      decoration: const InputDecoration(
                        labelText: 'Assignment Name',
                      ),
                      onSaved: (value) => _className = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Assignment name';
                        }
                        return null;
                      },
                    ),
                    verticalGap(context, 0.01),
                    TextFormField(
                      controller: description,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    verticalGap(context, 0.01),
                    TextFormField(
                      controller: marks,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Marks'),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    verticalGap(context, 0.01),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Select Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true, // Prevents the keyboard from showing up
                      onTap: () {
                        FocusScope.of(context).requestFocus(
                            FocusNode()); // Prevents focus on the text field
                        _selectDate(context); // Call the date picker function
                      },
                    ),
                    verticalGap(context, 0.01),
                    TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Select Time',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true, // Prevents the keyboard from showing up
                      onTap: () {
                        FocusScope.of(context).requestFocus(
                            new FocusNode()); // Prevents focus on the text field
                        _selectTime(context); // Call the time picker function
                      },
                    ),
                    TextFormField(
                      controller: _controller,
                      readOnly: true,
                      onTap: pickFiles,
                      decoration: const InputDecoration(
                        labelText: 'Select File',
                        suffixIcon: Icon(Icons.attach_file),
                      ),
                    ),
                    verticalGap(context, 0.01),
                    TextFormField(
                      controller: deductMarks,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Late Submission Deduction Marks'),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    verticalGap(context, 0.02),
                    Row(
                      children: [
                        Checkbox(
                            value: checkBoxValue,
                            onChanged: (value) {
                              setState(() {
                                checkBoxValue = value!;
                              });
                            }),
                        Text(
                          "Allow Late Submissions",
                          style:
                              TextStyle(fontSize: responsiveSize(20, context)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
