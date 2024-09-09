// Datenmodell für Buchungen (Bookings)
class Booking {
  final String parkingLot;
  final String date;
  final String timeslot;

  Booking({
    required this.parkingLot,
    required this.date,
    required this.timeslot,
  });

  // JSON in Booking-Objekt konvertieren
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      parkingLot: json['parking_lot'],
      date: json['date'],
      timeslot: json['timeslot'],
    );
  }
}