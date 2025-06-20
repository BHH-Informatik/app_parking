import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumskonvertierung
import 'service/api_service.dart'; // ApiService importieren
import 'model/bookings.dart'; // Booking Model importieren

// Buchungen Seiten
class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  late Future<List<Booking>> bookings;
  final ApiService apiService = ApiService(); // API Service Initialisieren
  int? _sortColumnIndex;
  bool _isAscending = true;

  void _sort<T>(Comparable<T> Function(Booking b) getField, int columnIndex, bool ascending, List<Booking> bookings) {
    bookings.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  num _extractParkingLotNumber(String input) {
    final match = RegExp(r'\d+').firstMatch(input);
    if (match != null) {
      return num.parse(match.group(0)!);
    }
    return double.infinity; // falls keine Zahl enthalten ist – kommt ans Ende
  }



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
      appBar: AppBar(
        title: Text('Buchungen', style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
        )),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
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
              return SingleChildScrollView( // Hier wird das Scrollen ermöglicht
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ihre gebuchten Parkplätze',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    buildTable(snapshot.data!), // Baue die Tabelle basierend auf den Buchungsdaten
                  ],
                ),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // bei Bedarf scrollbar
        child: DataTable(
          columnSpacing: 25,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _isAscending,
          columns: [
            DataColumn(
              label: const Text('Parkplatz'),
              onSort: (columnIndex, ascending) {
                _sort<num>(
                      (b) => _extractParkingLotNumber(b.parkingLot),
                  columnIndex,
                  ascending,
                  data,
                );
              },

            ),
            DataColumn(
              label: const Text('Datum'),
              onSort: (columnIndex, ascending) {
                _sort<String>((b) => b.date, columnIndex, ascending, data);
              },
            ),
            DataColumn(
              label: const Text('Zeitslot'),
              onSort: (columnIndex, ascending) {
                _sort<String>(
                      (b) => formatTimeSlot(b.startTime, b.endTime),
                  columnIndex,
                  ascending,
                  data,
                );
              },
            ),
          ],
          rows: data.map((booking) {
            return DataRow(cells: [
              DataCell(Text(booking.parkingLot)),
              DataCell(Text(formatGermanDate(booking.date))),
              DataCell(Text(formatTimeSlot(booking.startTime, booking.endTime))),
            ]);
          }).toList(),
        ),
      ),
    );
  }


  Widget tableHeader(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }
}
