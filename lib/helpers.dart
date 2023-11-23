import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pesuclassrooms/Screens/classSection/modal/model.dart';
import 'package:pesuclassrooms/Screens/classSection/view/classDetails.dart';

const darkBlue = Color.fromARGB(23, 20, 32, 255);
const lightWhite = Colors.white60;
const white = Colors.white;
const font = GoogleFonts.poppins;
double responsiveSize(double size, BuildContext context) {
  return (size / MediaQuery.of(context).devicePixelRatio) * 2;
}

Widget verticalGap(context, _height) {
  final height = MediaQuery.of(context).size.height;
  return SizedBox(
    height: height * _height,
  );
}

Widget horizontalGap(context, _width) {
  final width = MediaQuery.of(context).size.width;
  return SizedBox(
    width: width * _width,
  );
}

class Style {
  TextStyle heading(context) {
    return TextStyle(
        fontSize: responsiveSize(24, context),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2);
  }

  TextStyle description(context, color) {
    return TextStyle(
        fontSize: responsiveSize(20, context),
        letterSpacing: 0.2,
        color: color);
  }
}

Future callLambdaFunction(apiEndpoint, requestData) async {
  try {
    var query = Uri(queryParameters: requestData).query;

    var url = Uri.parse('$apiEndpoint?$query');

    final response = await http.post(
      url,
      body: requestData,
    );

    if (response.statusCode == 200) {
      debugPrint("*************LAMBDA-SUCCESS************");
      return json.decode(response.body);
    } else {
      debugPrint(response.body);
      debugPrint("*************LAMBDA-FAILED************");
    }
  } catch (e) {
    throw Exception("$e");
  }
}

class ClassCard extends StatelessWidget {
  final String className;
  final String teacherName;
  final String section;
  final String classTime;
  final int classId;
  final String teacherId;
  final String description;
  final String sem;
  final String classCode;
  const ClassCard({
    Key? key,
    required this.className,
    required this.teacherName,
    required this.classTime,
    required this.section,
    required this.classId,
    required this.teacherId,
    required this.sem,
    required this.description,
    required this.classCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    final randomImageUrl = bgImageList[Random().nextInt(bgImageList.length)];
    return GestureDetector(
        onTap: () {
          var classDetail = ClassDetail(
              name: className,
              classId: classId,
              sem: sem,
              description: description,
              teacherId: teacherId,
              classCode: classCode,
              section: section,
              teacherName: teacherName,
              bgUrl: randomImageUrl);
          Navigator.push(
              context,
              PageTransition(
                  child: ClassDetails(
                    classDetails: classDetail,
                  ),
                  type: PageTransitionType.rightToLeft));
        },
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: CachedNetworkImage(
            imageUrl: randomImageUrl,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: responsiveSize(30, context),
                    horizontal: responsiveSize(20, context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstLetterCapital(className),
                      style: TextStyle(
                          fontSize: responsiveSize(24, context),
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    SizedBox(height: responsiveSize(40, context)),
                    Text('Teacher: $teacherName',
                        style: TextStyle(
                            fontSize: responsiveSize(18, context),
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Time: $classTime',
                        style: TextStyle(
                            fontSize: responsiveSize(18, context),
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

String firstLetterCapital(String value) {
  return value.toString().split(" ").map((e) {
    if (e.length == 1 && !RegExp(r'[0-9]').hasMatch(e)) {
      return e.toUpperCase();
    } else {
      if (e == "") {
        return e;
      }
      return e[0].toUpperCase() + e.substring(1).toLowerCase();
    }
  }).join(" ");
}

String formatDateTimeForSql(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(dateTime);
}

DateTime combineDateTimeWithTime(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

DateTime parseDateFromString(String dateString) {
  return DateTime.parse(dateString);
}

// TimeOfDay parseTimeFromString(String timeString) {
//   final hour = int.parse(timeString.split(":")[0]);
//   final minute = int.parse(timeString.split(":")[1]);
//   return TimeOfDay(hour: hour, minute: minute);
// }

TimeOfDay parseTimeFromString(String timeString) {
  int hour, minute;
  List<String> parts = timeString.split(' ');

  if (parts.length == 2) {
    List<String> timeParts = parts[0].split(':');
    hour = int.parse(timeParts[0]);
    minute = int.parse(timeParts[1]);

    if (parts[1].toUpperCase() == 'PM' && hour != 12) {
      hour = hour + 12;
    } else if (parts[1].toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }
  } else {
    throw FormatException('Invalid time format');
  }

  return TimeOfDay(hour: hour, minute: minute);
}
