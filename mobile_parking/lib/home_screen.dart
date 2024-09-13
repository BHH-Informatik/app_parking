import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumformatierung
import '../model/parking_lot.dart';
import '../model/parking_lot_status.dart';
import '../ui/booking_dialog.dart'; // Korrektes Import für den BookingDialog im ui Ordner
import '../service/api_service.dart'; // Importiere den API-Service

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ParkingLot>> parkingLots;
  final ApiService apiService = ApiService(); // Initialisiere den API-Service
  DateTime _selectedDate = DateTime.now(); // Aktuelles Datum

  @override
  void initState() {
    super.initState();
    _fetchParkingLots();
  }

  // Funktion zum Abrufen der Parkplätze für das ausgewählte Datum
  void _fetchParkingLots() {
    setState(() {
      parkingLots = fetchParkingLots();
    });
  }

  // Funktion zum Abrufen der Parkplätze basierend auf dem aktuellen Datum
  Future<List<ParkingLot>> fetchParkingLots() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<dynamic> parkingLotData = await apiService.fetchParkingLots(formattedDate);
    return parkingLotData.map((data) => ParkingLot.fromJson(data)).toList();
  }

  // Funktion zum Ändern des Datums
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _fetchParkingLots(); // Aktualisiere die API-Anfrage mit dem neuen Datum
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Obere Leiste mit Datum und Pfeilen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () => _changeDate(-1),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),
          // Tabelle der Parkplätze
          FutureBuilder<List<ParkingLot>>(
            future: parkingLots,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else {
                return Expanded(
                  child: SingleChildScrollView(
                    child: buildTable(snapshot.data!),
                  ),
                );
              }
            },
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Reduziertes Padding
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
    bool isBlockedByUser = parkingLot.status == ParkingLotStatus.blockedByUser;
    bool isTimeRangeBlocked = parkingLot.status == ParkingLotStatus.timeRangeBlocked;

    return InkWell(
      onTap: (isFree || isBlockedByUser || isTimeRangeBlocked)
          ? () {
        if (isFree) {
          // Bei Status "Free" öffne den Buchungsdialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return BookingDialog(
                parkingLot: parkingLot,
                selectedDate: _selectedDate,
                onBookingSuccess: _fetchParkingLots, // Callback zur Aktualisierung nach Buchung
              );
            },
          );
        } else if (isBlockedByUser) {
          // Zeige dem Benutzer, dass er den Parkplatz selbst gebucht hat
          _showBookingInfo(parkingLot);
        } else if (isTimeRangeBlocked) {
          // Zeige die geblockten Zeiten an
          _showBlockedTimes(parkingLot);
        }
      }
          : null, // Kein onTap, wenn der Status "fullDayBlocked" oder "unknown" ist
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
              parkingLot.name, // Nur der Name des Parkplatzes in der Zelle
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

  // Zeigt einen Dialog an, der die Buchungsinformationen des Benutzers anzeigt
  void _showBookingInfo(ParkingLot parkingLot) {
    String bookingInfo = 'Sie haben diesen Parkplatz von ${parkingLot.startTime} bis ${parkingLot.endTime} gebucht.';

    if (parkingLot.startTime == null && parkingLot.endTime == null) {
      bookingInfo = 'Sie haben diesen Parkplatz ganztägig gebucht.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eigene Buchung'),
          content: Text(bookingInfo),
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

  // Zeigt einen Dialog an, der die geblockten Zeiträume anzeigt
  void _showBlockedTimes(ParkingLot parkingLot) {
    String blockedInfo = 'Dieser Parkplatz ist von ${parkingLot.startTime} bis ${parkingLot.endTime} blockiert.';

    if (parkingLot.startTime == null && parkingLot.endTime == null) {
      blockedInfo = 'Dieser Parkplatz ist ganztägig blockiert.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Parkplatz blockiert'),
          content: Text(blockedInfo),
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
}
