import 'package:flutter/material.dart';
import '../model/parking_lot.dart';

class BookingDialog extends StatefulWidget {
  final ParkingLot parkingLot;

  const BookingDialog({super.key, required this.parkingLot});

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  bool _isAllDay = true;  // Checkbox ist standardmäßig aktiviert
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Parkplatz Buchen - ${widget.parkingLot.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkbox für "ganztägig buchen"
          Row(
            children: [
              Checkbox(
                value: _isAllDay,
                onChanged: (bool? value) {
                  setState(() {
                    _isAllDay = value ?? false;
                  });
                },
              ),
              const Text('Ganztägig buchen'),
            ],
          ),
          if (!_isAllDay)
            Column(
              children: [
                // Button für Startzeit auswählen
                ElevatedButton(
                  onPressed: () {
                    _selectTime(context, isStartTime: true);
                  },
                  child: Text(_selectedStartTime != null
                      ? 'Startzeit: ${_selectedStartTime!.format(context)}'
                      : 'Startzeit auswählen'),
                ),
                const SizedBox(height: 8),
                // Button für Endzeit auswählen
                ElevatedButton(
                  onPressed: () {
                    _selectTime(context, isStartTime: false);
                  },
                  child: Text(_selectedEndTime != null
                      ? 'Endzeit: ${_selectedEndTime!.format(context)}'
                      : 'Endzeit auswählen'),
                ),
              ],
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            if (_isAllDay) {
              print('Ganztägig gebucht: ${widget.parkingLot.name}');
            } else {
              print('Gebucht: ${widget.parkingLot.name} von ${_selectedStartTime?.format(context)} bis ${_selectedEndTime?.format(context)}');
            }
            Navigator.of(context).pop();
          },
          child: const Text('Buchen'),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }
}
