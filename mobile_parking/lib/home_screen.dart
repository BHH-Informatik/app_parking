import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumformatierung
import 'model/parking_lot.dart';
import 'model/parking_lot_status.dart';
import 'ui/booking_dialog.dart';
import 'service/api_service.dart'; // Importiere den API-Service
import 'model/app_colors.dart';


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
          // Füge die beiden Buttons über der Datumsauswahl hinzu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                      _fetchParkingLots();
                    });
                  },
                  child: const Text('Heute'),
                ),
                ElevatedButton(
                  onPressed: () => _showAutoBookingDialog(), // Automatische Buchung
                  child: const Text('Automatisch buchen'),
                ),
              ],
            ),
          ),
          // Obere Leiste mit Datum und Pfeilen
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Kleineres Padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Linker Pfeil (einen Tag zurück)
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () => _changeDate(-1), // Einen Tag zurück
                ),
                // Aktuelles Datum in der Mitte
                Text(
                  DateFormat('dd.MM.yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Rechter Pfeil (einen Tag vor)
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () => _changeDate(1), // Einen Tag vor
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
          if (i + 1 < data.length) buildParkingLotCell(data[i + 1]) else
            Container(),
        ],
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Reduziertes Padding
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(width: 2.5, color: Theme
              .of(context)
              .colorScheme
              .tertiary),
          verticalInside: BorderSide(width: 2.5, color: Theme
              .of(context)
              .colorScheme
              .tertiary),
        ),
        children: rows,
      ),
    );
  }

    // Einzelne Zelle für einen Parkplatz, nur aktiv, wenn der Status "Free" ist
  Widget buildParkingLotCell(ParkingLot parkingLot) {
    bool isFullDayBlocked = parkingLot.status == ParkingLotStatus.fullDayBlocked;
    bool isTimeRangeBlocked = parkingLot.status == ParkingLotStatus.timeRangeBlocked;
    bool isBlockedByUser = parkingLot.status == ParkingLotStatus.blockedByUser;
    bool isFree = parkingLot.status == ParkingLotStatus.free;

    return InkWell(
      onTap: !isFullDayBlocked
          ? () {
        if (isFree) {
          // Öffne den Buchungsdialog für freie Parkplätze
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return BookingDialog(
                parkingLot: parkingLot,
                selectedDate: _selectedDate, // Das aktuelle Datum
                onBookingSuccess: _fetchParkingLots,
              );
            },
          );
        } else if (isBlockedByUser) {
          // Zeige einen Dialog, dass der Benutzer den Parkplatz selbst gebucht hat
          _showBookingInfo(parkingLot);
        } else if (isTimeRangeBlocked) {
          // Zeige die geblockten Zeiten an
          _showBlockedTimes(parkingLot);
        }
      }
          : null, // Kein onTap, wenn der Status "fullDayBlocked" ist
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: ThemeUtils.getColorDependingOnTheme(context, parkingLot.status), // Farbe basierend auf dem Status
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              parkingLot.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ThemeUtils.getTextColorDependingOnTheme(context, parkingLot.status), // Textfarbe basierend auf Status
              ),
            ),
          ),
        ),
      ),
    );
  }

// Zeigt einen Dialog an, der die Buchungsinformationen des Benutzers anzeigt
  void _showBookingInfo(ParkingLot parkingLot) {
    BookingDialog.showBookingInfo(
      context,
      parkingLot,
      _fetchParkingLots,  // Callback nach erfolgreicher Stornierung
    );
  }


// Zeigt einen Dialog an, der die geblockten Zeiträume anzeigt
  void _showBlockedTimes(ParkingLot parkingLot) {
    final startTime = parkingLot.startTime; // Hol dir die Startzeit
    final endTime = parkingLot.endTime;     // Hol dir die Endzeit

    BookingDialog.showBlockedTimes(context, parkingLot, startTime, endTime);
  }


  void _showAutoBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingDialog(
          selectedDate: _selectedDate, // Das aktuelle Datum
          onBookingSuccess: _fetchParkingLots,
        );
      },
    );
  }
}
