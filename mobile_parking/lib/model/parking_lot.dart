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
    var status = ParkingLotStatusExtension.fromString(json['status']);
    if (json['extras'].length > 0) {
      if (json['extras']['blocked_by_user'] == true) {
        status = ParkingLotStatus.blockedByUser;
      }
    }
    var parkingLot = ParkingLot(
      id: json['id'],
      name: json['name'],
      status: status,
    );
    return parkingLot;
  }
}
