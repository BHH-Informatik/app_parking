import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/parking_lot.dart';
import 'model/parking_lot_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ParkingLot>> parkingLots;

  @override
  void initState() {
    super.initState();
    parkingLots = fetchParkingLots();
  }

  // Fetch Parking Lots from API
  Future<List<ParkingLot>> fetchParkingLots() async {
    final response = await http.get(Uri.parse('https://kapanke.net/capstone/table'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body)['parking_lots'];
      return jsonResponse.map((data) => ParkingLot.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load parking lots');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<ParkingLot>>(
          future: parkingLots,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else {
              return buildTable(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  // Dynamische Tabelle basierend auf den API-Daten
  Widget buildTable(List<ParkingLot> data) {
    // Gruppiere die ParkingLots zu Zeilenpaaren, um zwei Namen nebeneinander anzuzeigen
    List<TableRow> rows = [];
    for (int i = 0; i < data.length; i += 2) {
      rows.add(TableRow(
        children: [
          // Erster Name in der Reihe
          buildParkingLotCell(data[i]),
          // Zweiter Name in der Reihe, falls vorhanden
          if (i + 1 < data.length) buildParkingLotCell(data[i + 1]) else Container(),
        ],
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: const TableBorder(
          horizontalInside: BorderSide(width: 2.5, color: Colors.black45),
          verticalInside: BorderSide(width: 2.5, color: Colors.black45),
        ),
        children: rows,
      ),
    );
  }

  // Einzelne Zelle für einen Parkplatz, anklickbar gemacht mit InkWell
  Widget buildParkingLotCell(ParkingLot parkingLot) {
    return InkWell(
      onTap: () {
        // Wenn eine Zelle angeklickt wird, zeige einen Dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BookingDialog(parkingLot: parkingLot);
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: parkingLot.status.color, // Hintergrundfarbe passend zum Status
              borderRadius: BorderRadius.circular(8.0), // Ecken rund machen
            ),
            child: Text(
              parkingLot.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: parkingLot.status.textColor, // Textfarbe basierend auf Status
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog zum Buchen eines Parkplatzes
class BookingDialog extends StatefulWidget {
  final ParkingLot parkingLot;

  const BookingDialog({super.key, required this.parkingLot});

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  bool _isAllDay = true;
  String? _selectedStartTime;
  String? _selectedEndTime;

  // Beispiel-Zeiten, könnte durch dynamische Zeitwerte ersetzt werden
  final List<String> _times = ['08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'];

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
                // Dropdown für Startzeit
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Startzeit'),
                  value: _selectedStartTime,
                  items: _times.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStartTime = newValue;
                    });
                  },
                ),
                // Dropdown für Endzeit
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Endzeit'),
                  value: _selectedEndTime,
                  items: _times.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedEndTime = newValue;
                    });
                  },
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
            // Hier könnte der Buchungsvorgang gestartet werden
            if (_isAllDay) {
              print('Ganztägig gebucht: ${widget.parkingLot.name}');
            } else {
              print('Gebucht: ${widget.parkingLot.name} von $_selectedStartTime bis $_selectedEndTime');
            }
            Navigator.of(context).pop();
          },
          child: const Text('Buchen'),
        ),
      ],
    );
  }
}
