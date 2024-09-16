import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumskonvertierung
import 'service/api_service.dart'; // ApiService importieren
import 'model/bookings.dart'; // Booking Model importieren

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  late Future<List<Booking>> bookings;
  final ApiService apiService = ApiService(); // API Service Initialisieren

  @override
  void initState() {
    super.initState();
    bookings = fetchBookings();
  }

  // Buchungen von der API abrufen
  Future<List<Booking>> fetchBookings() async {
    List<dynamic> bookingData = await apiService.fetchUserBookings();
    return bookingData.map((data) => Booking.fromJson(data)).toList();
  }

  // Konvertiert das Datum ins deutsche Format DD.MM.YYYY
  String formatGermanDate(String dateString) {
    DateTime date = DateTime.parse(dateString); // Datum von String zu DateTime
    return DateFormat('dd.MM.yyyy').format(date); // Datum ins deutsche Format
  }

  // Zeit in ganztägig umwandeln, wenn Start- und Endzeit leer sind
  String formatTimeSlot(String? startTime, String? endTime) {
    if (startTime == null && endTime == null) {
      return 'Ganztägig';
    }

    String formatTime(String time) {
      DateTime parsedTime = DateFormat("HH:mm:ss").parse(time); // Parse mit Sekunden
      return DateFormat('HH:mm').format(parsedTime); // Format nur Stunden und Minuten
    }

    String formattedStartTime = startTime != null ? formatTime(startTime) : '';
    String formattedEndTime = endTime != null ? formatTime(endTime) : '';

    return '$formattedStartTime - $formattedEndTime';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Booking>>(
          future: bookings,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Keine Buchungen gefunden');
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ihre gebuchten Parkplätze',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan.shade800,
                      ),
                    ),
                  ),
                  buildTable(snapshot.data!),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Dynamische Tabelle mit den Spalten Parkplatz, Datum und Zeitslot
  Widget buildTable(List<Booking> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: const TableBorder(
          horizontalInside: BorderSide(width: 2.0, color: Colors.white),
          verticalInside: BorderSide(width: 2.0, color: Colors.white),
        ),
        children: [
          TableRow(
            children: [
              tableHeader('Parkplatz'),
              tableHeader('Datum'),
              tableHeader('Zeitslot'),
            ],
          ),
          ...data.map((booking) {
            return TableRow(
              children: [
                tableCell(booking.parkingLot),
                tableCell(formatGermanDate(booking.date)),
                tableCell(formatTimeSlot(booking.startTime, booking.endTime)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget tableHeader(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.cyan.shade200,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget tableCell(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.cyan.shade50,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
