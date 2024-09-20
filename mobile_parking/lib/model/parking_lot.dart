// models/parking_lot.dart

import 'parking_lot_status.dart';

// Datenmodell für ParkingLots
class ParkingLot {
  final int id;
  final String name;
  final ParkingLotStatus status;
  final String? startTime;
  final String? endTime;
  final String? bookingId;

  ParkingLot({
    required this.id,
    required this.name,
    required this.status,
    this.startTime,
    this.endTime,
    this.bookingId,
  });

  // Konvertiert JSON zu einem ParkingLot-Objekt
  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    var status = ParkingLotStatusExtension.fromString(json['status']);
    var startTime;
    var endTime;
    var bookingId;
    if (json['extras'].length > 0) {
      if (status == ParkingLotStatus.timeRangeBlocked) {
        startTime = json['extras']['start_time'];
        endTime = json['extras']['end_time'];
      }
      if (json['extras']['blocked_by_user'] == true) {
        status = ParkingLotStatus.blockedByUser;
        bookingId = json['extras']['booking_id'].toString();
      }
    }
    var parkingLot = ParkingLot(
      id: json['id'],
      name: json['name'],
      status: status,
      startTime: startTime,
      endTime: endTime,
      bookingId: bookingId,
    );
    return parkingLot;
  }
}
