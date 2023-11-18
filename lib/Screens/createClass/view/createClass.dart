import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pesuclassrooms/Screens/classSection/view/classDetails.dart';
import 'package:pesuclassrooms/helpers.dart';

import '../controller/createClass.dart';

class CreateClass extends StatefulWidget {
  const CreateClass({Key? key}) : super(key: key);

  @override
  State<CreateClass> createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  final _formKey = GlobalKey<FormState>();
  String _className = '';
  String _description = '';
  bool isLoading = false;
  String _section = '';
  @override
  Widget build(BuildContext context) {
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
                        _formKey, _className, _description, _section, context)
                    .then((value) {
                  setState(() {
                    isLoading = false;
                  });

                  Navigator.pushReplacement(
                      context,
                      PageTransition(
                          child: ClassDetails(
                            className: _className,
                            teacherId: FirebaseAuth.instance.currentUser!.uid,
                            section: _section,
                            subject: _section,
                          ),
                          type: PageTransitionType.leftToRight));
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
            const LinearProgressIndicator(
              color: Colors.blueAccent,
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
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
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      onSaved: (value) => _description = value ?? '',
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Section'),
                      onSaved: (value) => _section = value ?? '',
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
