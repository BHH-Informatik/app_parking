import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Um das Datum zu formatieren
import 'model/parking_lot.dart';
import 'model/parking_lot_status.dart';
import 'ui/booking_dialog.dart';
import 'service/api_service.dart'; // Importiere den API-Service

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ParkingLot>> parkingLots;
  final ApiService apiService = ApiService(); // Initialisiere den API-Service

  @override
  void initState() {
    super.initState();
    parkingLots = fetchParkingLots();
  }

  // Hole die Parkplätze vom API-Service
  Future<List<ParkingLot>> fetchParkingLots() async {
    // Hole das heutige Datum im Format YYYY-MM-DD
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    // Verwende den ApiService, um die Daten zu laden
    List<dynamic> parkingLotData = await apiService.fetchParkingLots(formattedDate);

    // Mappe die Daten auf ParkingLot-Objekte
    return parkingLotData.map((data) => ParkingLot.fromJson(data)).toList();
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
    List<TableRow> rows = [];
    for (int i = 0; i < data.length; i += 2) {
      rows.add(TableRow(
        children: [
          buildParkingLotCell(data[i]),
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

  // Einzelne Zelle für einen Parkplatz, nur aktiv, wenn der Status "Free" ist
  Widget buildParkingLotCell(ParkingLot parkingLot) {
    bool isFree = parkingLot.status == ParkingLotStatus.free;

    return InkWell(
      onTap: isFree
          ? () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return BookingDialog(parkingLot: parkingLot);
          },
        );
      }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: parkingLot.status.color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              parkingLot.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: parkingLot.status.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
