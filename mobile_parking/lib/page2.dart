import 'package:flutter/material.dart';
import 'package:mobile_parking/model/bookings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../service/api_service.dart';
import 'ui/booking_dialog.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final ApiService apiService = ApiService();

  // Map zum Speichern der hervorgehobenen Tage (basierend auf den API-Daten)
  Map<DateTime, Map<String, dynamic>> _bookedDays = {};

  @override
  void initState() {
    super.initState();
    fetchBookings(); // Lade Buchungen beim Initialisieren der Seite
  }

  // Buchungen von der API abrufen
  Future<void> fetchBookings() async {
    try {
      List<dynamic> bookingsJson = await apiService.fetchUserBookings();

      setState(() {
        _bookedDays = {
          for (var booking in bookingsJson)
          // Setze die Zeit auf 00:00:00, um sicherzustellen, dass wir nur nach dem Datum vergleichen
            DateTime.parse(booking['booking_date']).toLocal().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0): booking,
        };
      });
    } catch (e) {
      print('Fehler beim Abrufen der Buchungen: $e');
    }
  }

  // Dialog anzeigen, wenn ein bereits gebuchter Tag angeklickt wird
  void _showBookingDetails(Map<String, dynamic> booking) {
    String timeSlot = 'Ganztägig';
    if (booking['start_time'] != null && booking['end_time'] != null) {
      timeSlot = '${booking['start_time']} - ${booking['end_time']}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Buchungsdetails'),
          content: Text(
            'Parkplatz: ${booking['parking_lot_id']}\nDatum: ${DateFormat('dd.MM.yyyy').format(DateTime.parse(booking['booking_date']))}\nZeitraum: $timeSlot',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Dialog für das automatische Buchen eines Parkplatzes
  void _showBookingDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingDialog(
            selectedDate: selectedDate,
            onBookingSuccess: fetchBookings);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                // Setze die Uhrzeit für den Vergleich auf 00:00:00
                DateTime selectedDayWithoutTime =
                DateTime(selectedDay.year, selectedDay.month, selectedDay.day)
                    .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);

                if (_bookedDays.containsKey(selectedDayWithoutTime)) {
                  _showBookingDetails(_bookedDays[selectedDayWithoutTime]!);
                } else {
                  _showBookingDialog(selectedDay);
                }
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  DateTime localDay = DateTime(day.year, day.month, day.day);
                  if (_bookedDays.containsKey(localDay.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0))) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Theme.of(context).colorScheme.surface),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ausgewähltes Datum: ${_selectedDay.day}.${_selectedDay.month}.${_selectedDay.year}',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
