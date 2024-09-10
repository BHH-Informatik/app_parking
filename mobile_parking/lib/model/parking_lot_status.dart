// models/parking_lot_status.dart

import 'package:flutter/material.dart';

// Enum für den Status
enum ParkingLotStatus { free, blocked, unknown }

// Extension für zusätzliche Methoden und Eigenschaften des Enums
extension ParkingLotStatusExtension on ParkingLotStatus {
  // Wandelt den Status von String zu Enum
  static ParkingLotStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'FREE':
        return ParkingLotStatus.free;
      case 'BLOCKED':
        return ParkingLotStatus.blocked;
      default:
        return ParkingLotStatus.unknown;
    }
  }

  // Gibt die Hintergrundfarbe basierend auf dem Status zurück
  Color get color {
    switch (this) {
      case ParkingLotStatus.free:
        return Colors.green.shade100;
      case ParkingLotStatus.blocked:
        return Colors.red.shade100;
      case ParkingLotStatus.unknown:
      default:
        return Colors.grey.shade100;
    }
  }

  // Textfarbe passend zum Status
  Color get textColor {
    switch (this) {
      case ParkingLotStatus.free:
        return Colors.green.shade900;
      case ParkingLotStatus.blocked:
        return Colors.red.shade900;
      case ParkingLotStatus.unknown:
      default:
        return Colors.black54;           // Fallback schwarz
    }
  }

  // TODO: bisher nur vorsorglich drin
  // Gibt den Text zurück, der für den Status angezeigt werden soll
  String get displayName {
    switch (this) {
      case ParkingLotStatus.free:
        return 'Free';
      case ParkingLotStatus.blocked:
        return 'Blocked';
      case ParkingLotStatus.unknown:
      default:
        return 'Unknown';
    }
  }
}