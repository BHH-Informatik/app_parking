// models/parking_lot_status.dart
import 'package:flutter/material.dart';

// Enum für den Status
enum ParkingLotStatus { free, fullDayBlocked, timeRangeBlocked, blockedByUser, unknown }

// Extension für zusätzliche Methoden und Eigenschaften des Enums
extension ParkingLotStatusExtension on ParkingLotStatus {
  // Wandelt den Status von String zu Enum
  static ParkingLotStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'FREE':
        return ParkingLotStatus.free;
      case 'FULL_DAY_BLOCKED':
        return ParkingLotStatus.fullDayBlocked;
      case 'TIMERANGE_BLOCKED':
        return ParkingLotStatus.timeRangeBlocked;
      case 'BLOCKED_BY_USER':
        return ParkingLotStatus.blockedByUser;
      default:
        return ParkingLotStatus.unknown;
    }
  }
}