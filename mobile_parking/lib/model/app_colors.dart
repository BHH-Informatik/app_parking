import 'parking_lot_status.dart';
import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color.fromARGB(255,252,109,92), // main color 1
  onPrimary: Color.fromARGB(255,255,204,151), // main color 2

  secondary: Color.fromARGB(255,3,146,163), // main color 3
  onSecondary: Color.fromARGB(255,0,51,104), // main color 4
  
  tertiary: Color.fromARGB(103, 182, 137, 89),
  onTertiary: Color.fromARGB(64, 3,146,163),

  error: Color.fromARGB(255, 244, 67, 54),
  onError: Color.fromARGB(255, 245, 178, 201),

  onSurface:  Color.fromARGB(255, 99, 74, 47),
  surface:  Color.fromARGB(255, 255, 244, 233), // background color


);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color.fromARGB(255,3,146,163), // main color 3
  onPrimary: Color.fromARGB(255,0,51,104), // main color 4

  secondary: Color.fromARGB(192, 252, 108, 92), // main color 1
  onSecondary: Color.fromARGB(255, 255, 205, 151), // main color 2
  
  tertiary: Color.fromARGB(255, 35, 63, 78),
  onTertiary: Color.fromARGB(118, 0, 150, 167),

  error: Colors.red,
  onError: Color.fromARGB(255, 255, 152, 152),

  onSurface: Color.fromARGB(255, 168, 173, 218),
  surface: Color.fromARGB(255, 47, 49, 73), // background color

);

class ThemeUtils {
  static Color getColorDependingOnTheme(BuildContext context, ParkingLotStatus status) {
    if (Theme.of(context).colorScheme.brightness.index == 0) { // Darkmode
      switch (status) {
        case ParkingLotStatus.free:
          return Color.fromARGB(64, 107, 135, 158);
        case ParkingLotStatus.fullDayBlocked:
          return const Color.fromARGB(50, 252, 108, 92);
        case ParkingLotStatus.timeRangeBlocked:
          return const Color.fromARGB(127, 255, 205, 151);
        case ParkingLotStatus.blockedByUser:
          return const Color.fromARGB(127, 3, 147, 163);
        case ParkingLotStatus.unknown:
        default:
          return const Color.fromARGB(64, 245, 245, 245);
      }
    } else if (Theme.of(context).colorScheme.brightness.index == 1) { // Lightmode
      switch (status) {
        case ParkingLotStatus.free:
          return Color.fromARGB(64, 107, 135, 158);
        case ParkingLotStatus.fullDayBlocked:
          return const Color.fromARGB(127, 252, 108, 92);
        case ParkingLotStatus.timeRangeBlocked:
          return const Color.fromARGB(127, 255, 205, 151);
        case ParkingLotStatus.blockedByUser:
          return const Color.fromARGB(127, 3, 147, 163);
        case ParkingLotStatus.unknown:
        default:
          return const Color.fromARGB(64, 245, 245, 245);
      }
    } else {
      return Color.fromARGB(255, 204, 0, 153);
    }
  }

  static Color getTextColorDependingOnTheme(BuildContext context, ParkingLotStatus status) {
    if (Theme.of(context).colorScheme.brightness.index == 0) { // Darkmode
      switch (status) {
        case ParkingLotStatus.free:
          return Color.fromARGB(255, 0, 0, 0);
        case ParkingLotStatus.fullDayBlocked:
          return Colors.red.shade600;
        case ParkingLotStatus.timeRangeBlocked:
          return Colors.orange.shade500;
        case ParkingLotStatus.blockedByUser:
          return Colors.cyan.shade600;
        case ParkingLotStatus.unknown:
        default:
          return Colors.black54;
      }
    } else if (Theme.of(context).colorScheme.brightness.index == 1) { // Lightmode
      switch (status) {
        case ParkingLotStatus.free:
          return Color.fromARGB(255, 0, 0, 0);
        case ParkingLotStatus.fullDayBlocked:
          return Colors.red.shade900;
        case ParkingLotStatus.timeRangeBlocked:
          return Colors.yellow.shade900;
        case ParkingLotStatus.blockedByUser:
          return Colors.cyan.shade900;
        case ParkingLotStatus.unknown:
        default:
          return Colors.black54;
      }
    } else {
      return Color.fromARGB(255, 204, 0, 153);
    }
  }
}

