import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/parking_lot.dart';
import '../service/api_service.dart'; // Importiere den API-Service

class BookingDialog extends StatefulWidget {
  final ParkingLot parkingLot;
  final DateTime selectedDate;
  final VoidCallback onBookingSuccess; // Callback, der nach einer erfolgreichen Buchung aufgerufen wird

  const BookingDialog({
    super.key,
    required this.parkingLot,
    required this.selectedDate,
    required this.onBookingSuccess, // Füge den Callback hinzu
  });

  @override
  _BookingDialogState createState() => _BookingDialogState();


  // Statische Methode, um den Dialog für eigene Buchungen anzuzeigen
  static void showBookingInfo(BuildContext context, ParkingLot parkingLot, VoidCallback onBookingCancel) {
    // Überprüfe, ob die Buchung ganztägig ist oder für einen bestimmten Zeitraum
    String bookingInfo;
    if (parkingLot.startTime == null && parkingLot.endTime == null) {
      bookingInfo = 'Ganztägig gebucht';
    } else {
      bookingInfo = 'Gebucht von ${parkingLot.startTime ?? "Unbekannt"} bis ${parkingLot.endTime ?? "Unbekannt"}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eigene Buchung'),
          content: Text(bookingInfo),
          actions: [
            // Button zum Stornieren der Buchung
            TextButton(
              onPressed: () async {
                final apiService = ApiService();
                try {
                  await apiService.cancelBooking(parkingLot.bookingId); // Buchung stornieren
                  onBookingCancel(); // Aktualisiere die UI nach dem Stornieren
                  Navigator.of(context).pop(); // Dialog schließen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buchung erfolgreich storniert')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fehler beim Stornieren der Buchung')),
                  );
                }
              },
              child: const Text('Stornieren'),
            ),
            // Schließen-Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


// Statische Methode, um den Dialog für geblockte Zeiträume anzuzeigen
  static void showBlockedTimes(BuildContext context, ParkingLot parkingLot, String? startTime, String? endTime) {
    String timeSlot;

    if (startTime != null && endTime != null) {
      startTime = formatTime(startTime);
      endTime = formatTime(endTime);
      timeSlot = 'Blockiert von $startTime bis $endTime Uhr.';
    } else {
      timeSlot = 'Dieser Parkplatz ist ganztägig blockiert.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Parkplatz blockiert'),
          content: Text(timeSlot),  // Zeige die blockierten Zeiten an
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

  static String formatTime(String time) {
    DateTime parsedTime = DateFormat("HH:mm:ss").parse(time); // Parse mit Sekunden
    return DateFormat('HH:mm').format(parsedTime); // Format nur Stunden und Minuten
  }
}

class _BookingDialogState extends State<BookingDialog> {
  final ApiService apiService = ApiService();
  bool _isAllDay = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false; // Ladeanzeige für die Buchung

  // Funktion zum Buchen des Parkplatzes
  Future<void> _bookParkingLot() async {
    setState(() {
      _isLoading = true;
    });

    // Formatiere das ausgewählte Datum für die API-Anfrage
    final String bookingDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    try {
      await apiService.bookParkingLot(
        parkingLotId: widget.parkingLot.id,
        bookingDate: bookingDate,
        startTime: !_isAllDay && _startTime != null ? _startTime!.format(context) : null,
        endTime: !_isAllDay && _endTime != null ? _endTime!.format(context) : null,
      );

      // Zeige Erfolgsmeldung und schließe den Dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parkplatz erfolgreich gebucht!')),
      );
      // Schließe den Dialog und rufe den Callback auf, um die Daten neu zu laden
      widget.onBookingSuccess(); // Rufe den Callback auf
      Navigator.of(context).pop();
    } catch (e) {
      // Fehlermeldung anzeigen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler bei der Buchung des Parkplatzes')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Funktion zum Auswählen der Zeit
  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Parkplatz ${widget.parkingLot.name} buchen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkbox für ganztägig buchen
          Row(
            children: [
              Checkbox(
                value: _isAllDay,
                onChanged: (bool? value) {
                  setState(() {
                    _isAllDay = value ?? true;
                  });
                },
              ),
              const Text('Ganztägig buchen'),
            ],
          ),
          if (!_isAllDay) ...[
            // Auswahl für Start- und Endzeiten, wenn nicht ganztägig gebucht wird
            ElevatedButton(
              onPressed: () => _selectTime(context, isStartTime: true),
              child: Text(_startTime != null
                  ? 'Startzeit: ${_startTime!.format(context)}'
                  : 'Startzeit auswählen'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectTime(context, isStartTime: false),
              child: Text(_endTime != null
                  ? 'Endzeit: ${_endTime!.format(context)}'
                  : 'Endzeit auswählen'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        if (!_isLoading) // Ladeanzeige während der Buchung
          ElevatedButton(
            onPressed: _bookParkingLot,
            child: const Text('Buchen'),
          ),
        if (_isLoading) const CircularProgressIndicator(),
      ],
    );
  }
}