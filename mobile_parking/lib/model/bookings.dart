class Booking {
  final int id;
  final String parkingLot;
  final String date;
  final String? startTime;
  final String? endTime;

  Booking({
    required this.id,
    required this.parkingLot,
    required this.date,
    this.startTime,
    this.endTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      parkingLot: json['parking_lot_id'].toString(), // Parkplatz ID als String für Darstellung
      date: json['booking_date'],
      startTime: json['booking_start_time'],
      endTime: json['booking_end_time'],
    );
  }
}
