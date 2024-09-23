import 'package:flutter/material.dart';
import 'package:mobile_parking/model/parking_lot_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'main.dart'; // Importiere MyHomePage für den Fall, dass der Benutzer sich ausloggt
import 'model/app_colors.dart';


// Einstellungen Seite
class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  ThemeMode themeMode = ThemeMode.system;
  bool _isLoggedIn = false; // Login-Status

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Prüfe, ob der Benutzer eingeloggt ist
  }

  // Prüfe den Login-Status mit shared_preferences
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  // Funktion zum Logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Entferne den Login-Status
    await prefs.remove('access_token'); // Optional: Entferne auch den Access Token

    // Leite zum Login-Screen weiter
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Funktion zum Account löschen (aktuell nur simuliert)
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account löschen', style: TextStyle(color: Color.fromARGB(255, 255, 204, 151))),
        content: const Text('Möchten Sie Ihren Account wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account wurde gelöscht (simuliert).')),
      );
      await _logout();
    }
  }

  // Funktion zum Anzeigen der Legende
  void _showLegend() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Legende'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Parkplatz Overview',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Nicht zu lange Texte schreiben hier,sonst gibt das Overflow
              _buildLegendItem(context,
                  ThemeUtils.getColorDependingOnTheme(context, ParkingLotStatus.free),
                  'Freier Parkplatz'),
              _buildLegendItem(context,
                  ThemeUtils.getColorDependingOnTheme(context, ParkingLotStatus.fullDayBlocked),
                  'Den ganzen Tag reserviert'),
              _buildLegendItem(context,
                  ThemeUtils.getColorDependingOnTheme(context, ParkingLotStatus.timeRangeBlocked),
                  'Teilweise reserviert'),
              _buildLegendItem(context,
                  ThemeUtils.getColorDependingOnTheme(context, ParkingLotStatus.blockedByUser),
                  'Von Ihnen reserviert'),
              const SizedBox(height: 16),
              const Text(
                'Kalender',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildLegendItem(context, Theme.of(context).colorScheme.onPrimary, 'Heutiger Tag'),
              _buildLegendItem(context, Theme.of(context).colorScheme.secondary, 'Gebuchter Tag'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String description) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Text(description),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen', style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Choose your theme:',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => MyApp.of(context).changeTheme(ThemeMode.light),
                    child: const Text('Light')),
                ElevatedButton(
                    onPressed: () => MyApp.of(context).changeTheme(ThemeMode.dark),
                    child: const Text('Dark')),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _isLoggedIn ? 'Sie sind eingeloggt.' : 'Sie sind nicht eingeloggt.',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 20),
            _isLoggedIn
                ? ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            )
                : ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showLegend,
              child: const Text('Legende anzeigen'),
            ),
          ],
        ),
      ),
    );
  }
}
