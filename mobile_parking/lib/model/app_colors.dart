
import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color.fromARGB(255,252,109,92), // main color 1
  onPrimary: Color.fromARGB(255,255,204,151), // main color 2

  secondary: Color.fromARGB(255,3,146,163), // main color 3
  onSecondary: Color.fromARGB(255,0,51,104), // main color 4
  
  tertiary: Colors.amber,
  onTertiary: Color.fromARGB(255, 0, 151, 167),

  error: Color.fromARGB(255, 244, 67, 54),
  onError: Color.fromARGB(255, 140, 0, 255),

  onSurface: Color.fromARGB(255, 199, 61, 61),
  surface: Color.fromARGB(255, 222, 225, 255), // background color

);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color.fromARGB(255,252,109,92), // main color 1
  onPrimary: Color.fromARGB(255,255,204,151), // main color 2

  secondary: Color.fromARGB(255,3,146,163), // main color 3
  onSecondary: Color.fromARGB(255,0,51,104), // main color 4
  
  tertiary: Colors.amber,
  onTertiary: Color.fromARGB(255, 0, 151, 167),

  error: Colors.red,
  onError: Color.fromARGB(255, 255, 152, 152),

  onSurface: Color.fromARGB(255, 12, 132, 148),
  surface: Color.fromARGB(255, 47, 49, 73), // background color
);