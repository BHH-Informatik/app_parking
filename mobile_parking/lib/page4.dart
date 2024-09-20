import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'main.dart'; // Importiere MyHomePage für den Fall, dass der Benutzer sich ausloggt

// Einstellungen Seite
class Page4 extends StatefulWidget {
  const Page4({super.key});

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  // bool _isDarkMode = false; // Für den Dark Mode Switch
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
    await prefs
        .remove('access_token'); // Optional: Entferne auch den Access Token

    // Leite zum Login-Screen weiter
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // Funktion zum Account löschen (aktuell nur simuliert)
  Future<void> _deleteAccount() async {
    // Zeige einen Bestätigungsdialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account löschen', style: TextStyle(color:  Color.fromARGB(255,255,204,151)),),
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
      // Hier kannst du eine API-Anfrage hinzufügen, um den Account zu löschen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account wurde gelöscht (simuliert).')),
      );

      // Nach dem Löschen: Leite den Benutzer zum Login-Screen weiter
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen', style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary
        ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20,),
            Text(
              'Choose your theme:',
              style: TextStyle(
                fontSize: 18,
                color:  Theme.of(context).colorScheme.secondary),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// Change theme & rebuild to show it using these buttons 
                ElevatedButton(
                    onPressed: () => MyApp.of(context).changeTheme(ThemeMode.light),
                    child: const Text('Light')),
                ElevatedButton(
                    onPressed: () => MyApp.of(context).changeTheme(ThemeMode.dark),
                    child: const Text('Dark')),
              ],
            ),
          const SizedBox(height: 20),

          // Zeige, ob der Benutzer eingeloggt ist
          Text(
            _isLoggedIn ? 'Sie sind eingeloggt.' : 'Sie sind nicht eingeloggt.',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 20),

          // Login-/Logout-Button basierend auf dem Login-Status
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

          // Account löschen Button - Mertens möchte keine DSGVO
          // if (_isLoggedIn) // Nur anzeigen, wenn der Benutzer eingeloggt ist
          //   ElevatedButton(
          //     onPressed: _deleteAccount,
          //     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          //     child: Text('Account löschen', style: TextStyle(
          //       color: Theme.of(context).colorScheme.surface,
          //     ),
          //     ),
          //   ),
        ],
      ),
    ));
  }
}
