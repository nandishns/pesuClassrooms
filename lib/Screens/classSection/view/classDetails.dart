import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pesuclassrooms/Screens/classSection/view/classWork.dart';
import 'package:pesuclassrooms/Screens/classSection/view/people.dart';
import 'package:pesuclassrooms/Screens/classSection/view/stream.dart';
import 'package:pesuclassrooms/Screens/createAssignment/createAssignment.dart';
import 'package:pesuclassrooms/helpers.dart';

import '../modal/model.dart';

class ClassDetails extends StatefulWidget {
  final ClassDetail classDetails;

  const ClassDetails({
    Key? key,
    required this.classDetails,
  }) : super(key: key);

  @override
  State<ClassDetails> createState() => _ClassDetailsState();
}

class _ClassDetailsState extends State<ClassDetails> {
  int _selectedIndex = 0;
  late bool isAdmin;
  @override
  void initState() {
    isAdmin =
        FirebaseAuth.instance.currentUser?.uid == widget.classDetails.teacherId;
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      Stream(
        classDetial: widget.classDetails,
      ),
      ClassWork(classId: widget.classDetails.classId, isAdmin: isAdmin),
      People(
        classID: widget.classDetails.classId,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showClassDetailsPopup(context, widget.classDetails);
              },
              icon: Icon(
                Icons.info_outline,
                size: responsiveSize(30, context),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, -1), // changes position of shadow
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.forum),
              label: 'Stream',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Classwork',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'People',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          elevation: 4,
          unselectedLabelStyle: TextStyle(
              fontSize: responsiveSize(16, context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2),
          selectedLabelStyle: TextStyle(
              fontSize: responsiveSize(18, context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: Visibility(
        visible: _selectedIndex == 1 &&
            FirebaseAuth.instance.currentUser?.uid ==
                widget.classDetails.teacherId,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    child: CreateAssignment(
                      classId: widget.classDetails.classId,
                    ),
                    type: PageTransitionType.rightToLeft));
          },
          backgroundColor: Colors.blueAccent,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: responsiveSize(40, context),
          ),
        ),
      ),
    );
  }
}

void showClassDetailsPopup(BuildContext context, ClassDetail classDetails) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          classDetails.name,
          style: TextStyle(
            fontSize: responsiveSize(24, context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(responsiveSize(20, context)),
            child: ListBody(
              children: <Widget>[
                Text(
                  'Description: ${classDetails.description}',
                  style: TextStyle(
                    fontSize: responsiveSize(20, context),
                  ),
                ),
                Text(
                  'Section: ${classDetails.section}',
                  style: TextStyle(
                    fontSize: responsiveSize(20, context),
                  ),
                ),
                Text(
                  'SEM: ${classDetails.sem}',
                  style: TextStyle(
                    fontSize: responsiveSize(20, context),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Class Code: ${classDetails.classCode}',
                        style: TextStyle(
                            fontSize: responsiveSize(20, context),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                                ClipboardData(text: classDetails.classCode))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Class code copied to clipboard')),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
