import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/parking_lot.dart';
import '../service/api_service.dart';

class BookingDialog extends StatefulWidget {
  final ParkingLot? parkingLot;
  final DateTime selectedDate;
  final VoidCallback onBookingSuccess;

  const BookingDialog({
    super.key,
    this.parkingLot,
    required this.selectedDate,
    required this.onBookingSuccess,
  });

  @override
  _BookingDialogState createState() => _BookingDialogState();


  // Statische Methode für eigene Buchungen
  static void showBookingInfo(BuildContext context, ParkingLot parkingLot, VoidCallback onBookingCancel) {
    String bookingInfo;
    if (parkingLot.startTime == null && parkingLot.endTime == null) {
      bookingInfo = 'Ganztägig gebucht';
    } else {
      bookingInfo = 'Gebucht von ${formatTime(parkingLot.startTime!)} bis ${formatTime(parkingLot.endTime!)} Uhr';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eigene Buchung'),
          content: Text(bookingInfo),
          actions: [
            TextButton(
              onPressed: () async {
                final apiService = ApiService();
                try {
                  await apiService.cancelBooking(parkingLot.bookingId);
                  onBookingCancel();
                  Navigator.of(context).pop();
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
          content: Text(timeSlot),
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
    DateTime parsedTime = DateFormat("HH:mm:ss").parse(time);
    return DateFormat('HH:mm').format(parsedTime);
  }
}


class _BookingDialogState extends State<BookingDialog> {
  final ApiService apiService = ApiService();
  bool _isAllDay = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  // Funktion zum Buchen des Parkplatzes
  Future<void> _bookParkingLot() async {
    setState(() {
      _isLoading = true;
    });

    final String bookingDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    try {
      if (widget.parkingLot != null) {
        // Normale Buchung
        await apiService.bookParkingLot(
          parkingLotId: widget.parkingLot!.id,
          bookingDate: bookingDate,
          startTime: !_isAllDay && _startTime != null ? _startTime!.format(context) : null,
          endTime: !_isAllDay && _endTime != null ? _endTime!.format(context) : null,
        );
      } else {
        // Automatische Buchung
        await apiService.autoBookParkingLot(
          bookingDate: bookingDate,
          startTime: !_isAllDay && _startTime != null ? _startTime!.format(context) : null,
          endTime: !_isAllDay && _endTime != null ? _endTime!.format(context) : null,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parkplatz erfolgreich gebucht!')),
      );
      widget.onBookingSuccess();
      Navigator.of(context).pop();
    } catch (e) {
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
      title: Text(widget.parkingLot != null
          ? 'Parkplatz ${widget.parkingLot!.name} buchen'
          : 'Automatische Buchung'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
        if (!_isLoading)
          ElevatedButton(
            onPressed: _bookParkingLot,
            child: const Text('Buchen'),
          ),
        if (_isLoading) const CircularProgressIndicator(),
      ],
    );
  }
}
