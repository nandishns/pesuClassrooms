import 'package:flutter/material.dart';
import 'package:pesuclassrooms/utils/assignmentTile.dart';

class ClassWork extends StatefulWidget {
  const ClassWork({Key? key}) : super(key: key);

  @override
  State<ClassWork> createState() => _ClassWorkState();
}

class _ClassWorkState extends State<ClassWork> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [assignmentTile("", "", context)],
    );
  }
}
