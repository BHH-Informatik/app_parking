
import 'package:flutter/material.dart';

// Light und Dark Theme für App
// class MyAppColors {
//   static const darkBlue = Color(0xFF1E1E2C);
//   static const lightBlue = Color(0xFF2D2D44);
// }

// class MyAppThemes {
//   static final lightTheme = ThemeData(
//     primaryColor: MyAppColors.lightBlue,
//     brightness: Brightness.light,
//   );

//   static final darkTheme = ThemeData(
//     primaryColor: MyAppColors.darkBlue,
//     brightness: Brightness.dark,
//   );
// }

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF96416A),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFD8E6),
  onPrimaryContainer: Color(0xFF3D0024),
  secondary: Color(0xFF735761),
  onSecondary: Color(0xFF412A33),
  error: Colors.red,
  onError: Color.fromARGB(255, 140, 0, 255),
  onSurface: Color.fromARGB(255, 199, 61, 61),
  surface: Color.fromARGB(255, 202, 164, 164),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB0D0),
  onPrimary: Color(0xFF5C113B),
  primaryContainer: Color(0xFF792952),
  onPrimaryContainer: Color(0xFFFFD8E6),
  secondary: Color(0xFFE1BDCA),
  onSecondary: Color(0xFF412A33),
  error: Colors.red,
  onError: Color.fromARGB(255, 255, 152, 152),
  onSurface: Color.fromARGB(255, 12, 132, 148),
  surface: Color.fromARGB(255, 128, 35, 35),
);