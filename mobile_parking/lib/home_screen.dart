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
            return AlertDialog(
              title: Text('Parkplatz Buchen'),
              content: Text('Möchten Sie den Parkplatz "${parkingLot.name}" buchen?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () {
                    // Hier könnte der Buchungsvorgang gestartet werden
                    Navigator.of(context).pop();
                  },
                  child: Text('Buchen'),
                ),
              ],
            );
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
