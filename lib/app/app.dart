import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pesuclassrooms/Screens/AuthScreens/view/googleAuthScreen.dart';
import 'package:pesuclassrooms/Screens/DashBoard/view/dashboard.dart';

import '../helpers.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PESU Classrooms',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
              fontSize: responsiveSize(26, context),
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: GoogleFonts.poppins().fontFamily),
        ),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser?.uid != null
          ? const DashBoard()
          : const GoogleAuthScreen(),
    );
  }
}
