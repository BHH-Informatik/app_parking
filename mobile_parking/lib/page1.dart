import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Für die Datumskonvertierung
import 'package:mobile_parking/model/app_colors.dart';
import 'model/bookings.dart';

// Bookings Seite 
class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  _Page1State createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  late Future<List<Booking>> bookings;

  @override
  void initState() {
    super.initState();
    bookings = fetchBookings();
  }

  // Fetch bookings from API
  Future<List<Booking>> fetchBookings() async {
    final response = await http.get(Uri.parse('https://kapanke.net/capstone/bookings'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> bookingsJson = jsonResponse['bookings'];
      return bookingsJson.map((data) => Booking.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  // Konvertiert das Datum ins deutsche Format DD.MM.YYYY
  String formatGermanDate(String dateString) {
    DateTime date = DateTime.parse(dateString); // Datum von String zu DateTime
    return DateFormat('dd.MM.yyyy').format(date); // Datum ins deutsche Format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buchungen', style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary
        ),
        ),
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
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center, // TODO: Falls das wirklich linksbündig soll .start
                children: [
                  // Überschrift mit eingefärbter Schrift
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ihre gebuchten Parkplätze',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary, // Schriftfarbe auf cyan.shade300 geändert
                      ),
                    ),
                  ),
                  // Tabelle
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
        border: TableBorder(
          horizontalInside: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.surface),
          verticalInside: BorderSide(width: 2.0, color: Theme.of(context).colorScheme.surface),
        ),
        children: [
          // Tabellenkopf
          TableRow(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,  // Hintergrundfarbe der ersten Zelle
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Parkplatz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,  // Hintergrundfarbe der zweiten Zelle
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Datum',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,  // Hintergrundfarbe der dritten Zelle
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Zeitslot',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface),
                ),
              ),
            ],
          ),
          // Dynamische Datenzeilen
          ...data.map((booking) {
            return TableRow(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,  // Leicht hellere Farbe für die Zeilen
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    booking.parkingLot,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,  // Leicht hellere Farbe für die Zeilen
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    formatGermanDate(booking.date),  // Datum ins deutsche Format konvertiert
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onTertiary,  // Leicht hellere Farbe für die Zeilen
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    booking.timeslot,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
