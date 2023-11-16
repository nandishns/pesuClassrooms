import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
