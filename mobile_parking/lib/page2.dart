import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Buchungen Seite
class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // Map zum Speichern der hervorgehobenen Tage (basierend auf den API-Daten)
  Map<DateTime, Color> _highlightedDays = {};

  @override
  void initState() {
    super.initState();
    fetchBookings(); // Lade Buchungen beim Initialisieren der Seite
  }

  // Fetch bookings from API
  Future<void> fetchBookings() async {
    final response = await http.get(Uri.parse('https://kapanke.net/capstone/bookings'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> bookingsJson = jsonResponse['bookings'];

      setState(() {
        // Map über die Buchungen erstellen und Tage markieren (Uhrzeit auf 00:00:00 setzen)
        _highlightedDays = {
          for (var booking in bookingsJson)
          // Stelle sicher, dass die Uhrzeit auf 00:00:00 gesetzt wird, damit der Vergleich funktioniert
            DateTime.parse(booking['date']).toLocal(): Colors.green.shade300
        };
        // print(_highlightedDays); // Ausgabe zur Überprüfung
      });
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        backgroundColor: Colors.cyan.shade300, // Optional: Hintergrundfarbe der AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Kalender anzeigen
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // Aktualisiere den fokussierten Tag
                });
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.cyan.shade200,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.cyan.shade300,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              // Verwende CalendarBuilders, um bestimmte Tage individuell zu gestalten
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // Setze die Uhrzeit auf 00:00:00, um nur das Datum zu vergleichen
                  DateTime localDay = DateTime(day.year, day.month, day.day);
                  if (_highlightedDays.containsKey(localDay)) {
                    return Container(
                      decoration: BoxDecoration(
                        color: _highlightedDays[localDay], // Farbe für gebuchte Tage (grün)
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return null; // Alle anderen Tage werden standardmäßig dargestellt
                },
              ),
            ),
            const SizedBox(height: 20),
            // Zeigt das ausgewählte Datum an
            Text(
              'Ausgewähltes Datum: ${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
