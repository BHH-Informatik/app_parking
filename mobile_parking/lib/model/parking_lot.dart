// models/parking_lot.dart

import 'parking_lot_status.dart';

// Datenmodell für ParkingLots
class ParkingLot {
  final int id;
  final String name;
  final ParkingLotStatus status;

  ParkingLot({
    required this.id,
    required this.name,
    required this.status,
  });

  // Konvertiert JSON zu einem ParkingLot-Objekt
  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    return ParkingLot(
      id: json['id'],
      name: json['name'],
      status: ParkingLotStatusExtension.fromString(json['status']),
    );
  }
}
