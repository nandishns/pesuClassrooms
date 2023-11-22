import 'package:flutter/material.dart';

import '../helpers.dart';

Widget assignmentTile(assignmentName, postedOn, context) {
  return ListTile(
    onTap: () {},
    leading: const CircleAvatar(
      backgroundColor: Colors.blueAccent,
      child: Icon(
        Icons.assignment,
        color: Colors.white,
      ),
    ),
    title: Text(
      "Assigment Name",
      style: TextStyle(fontSize: responsiveSize(18, context)),
    ),
    subtitle: Text(
      "Posted 18 Sept",
      style:
          TextStyle(fontSize: responsiveSize(16, context), color: Colors.grey),
    ),
    trailing: PopupMenuButton(itemBuilder: (context) {
      return [
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "Edit",
            style: Style().description(context, Colors.black),
          ),
        ),
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "Delete",
            style: Style().description(context, Colors.black),
          ),
        ),
      ];
    }, onSelected: (value) {
      if (value == 0) {
        //TODO: implement view deadlines
      }
    }),
  );
}
