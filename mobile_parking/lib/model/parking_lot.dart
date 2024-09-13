import 'parking_lot_status.dart';

// Datenmodell für ParkingLots
class ParkingLot {
  final int id;
  final String name;
  final ParkingLotStatus status;
  final String? startTime; // Startzeit der Buchung (optional)
  final String? endTime;   // Endzeit der Buchung (optional)

  ParkingLot({
    required this.id,
    required this.name,
    required this.status,
    this.startTime,
    this.endTime,
  });

  // Konvertiert JSON zu einem ParkingLot-Objekt
  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    var status = ParkingLotStatusExtension.fromString(json['status']);

    // Überprüfe, ob der Parkplatz vom Benutzer blockiert ist
    if (json['extras'].length > 0 && json['extras']['blocked_by_user'] == true) {
      status = ParkingLotStatus.blockedByUser;
    }

    // Extrahiere die Start- und Endzeiten, falls vorhanden
    return ParkingLot(
      id: json['id'],
      name: json['name'],
      status: status,
      startTime: json['start_time'],  // Optional: Startzeit
      endTime: json['end_time'],      // Optional: Endzeit
    );
  }
}
