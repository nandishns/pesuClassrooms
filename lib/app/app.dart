import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pesuclassrooms/Screens/AuthScreens/view/googleAuthScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PESU Classrooms',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: const ColorScheme.light(),
        useMaterial3: true,
      ),
      home: const GoogleAuthScreen(),
    );
  }
}
