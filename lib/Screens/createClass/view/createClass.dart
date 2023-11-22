import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pesuclassrooms/Screens/createClass/controller/createClass.dart';
import 'package:pesuclassrooms/helpers.dart';

class CreateClass extends StatefulWidget {
  const CreateClass({Key? key}) : super(key: key);

  @override
  State<CreateClass> createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? _className;
  String? _description;
  TextEditingController className = TextEditingController();
  TextEditingController description = TextEditingController();

  String? selectedSemester;
  String? selectedSection;
  String? isMembersAdded;
  final List bgImageList = [
    "https://www.gstatic.com/classroom/themes/img_code.jpg",
    "https://www.gstatic.com/classroom/themes/img_bookclub.jpg",
    "https://www.gstatic.com/classroom/themes/img_learnlanguage.jpg",
    "https://www.gstatic.com/classroom/themes/img_graduation.jpg",
    "https://www.gstatic.com/classroom/themes/img_reachout.jpg",
    "https://www.gstatic.com/classroom/themes/img_reachout.jpg",
    "https://www.gstatic.com/classroom/themes/img_arts.jpg",
    "https://www.gstatic.com/classroom/themes/Chemistry.jpg",
    "https://www.gstatic.com/classroom/themes/Physics.jpg",
    "https://www.gstatic.com/classroom/themes/img_learninstrument_thumb.jpg"
  ];

  @override
  Widget build(BuildContext context) {
    final randomImageUrl = bgImageList[Random().nextInt(bgImageList.length)];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create class",
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
              onPressed: () {
                setState(() {
                  isLoading = true;
                });

                createClass(
                        _formKey,
                        className.text,
                        description.text,
                        selectedSection,
                        selectedSemester,
                        context,
                        randomImageUrl)
                    .then((value) {
                  setState(() {
                    isLoading = false;
                  });
                });
              },
              child: Text(
                "Create Class",
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
                      controller: className,
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                      ),
                      onSaved: (value) => _className = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter class name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: description,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    verticalGap(context, 0.03),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Semester',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedSemester,
                      onChanged: (newValue) {
                        setState(() {
                          selectedSemester = newValue!;
                        });
                      },
                      items: List.generate(8, (index) => (index + 1).toString())
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    verticalGap(context, 0.03),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Section',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedSection,
                      onChanged: (newValue) {
                        setState(() {
                          selectedSection = newValue!;
                        });
                      },
                      items: List.generate(
                              13,
                              (index) => String.fromCharCode(
                                  'A'.codeUnitAt(0) + index))
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    verticalGap(context, 0.03),
                    // Visibility(
                    //   visible: selectedSection != null,
                    //   child: DropdownButtonFormField<String>(
                    //     decoration: InputDecoration(
                    //       labelText:
                    //           'Do you want to add all $selectedSection students',
                    //       border: const OutlineInputBorder(),
                    //     ),
                    //     value: isMembersAdded,
                    //     onChanged: (newValue) {
                    //       setState(() {
                    //         isAutomated = newValue!;
                    //       });
                    //     },
                    //     items: _bool.map<DropdownMenuItem<String>>((value) {
                    //       return DropdownMenuItem(
                    //         value: value,
                    //         child: Text(value),
                    //       );
                    //     }).toList(),
                    //   ),
                    // ),
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
