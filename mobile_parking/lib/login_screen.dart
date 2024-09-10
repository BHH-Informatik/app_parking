import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'main.dart'; // Importiere MyHomePage

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Funktion zum Speichern des Login-Status
  Future<void> _saveLoginStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  // Funktion zum Überspringen des Logins
  Future<void> _skipLogin() async {
    await _saveLoginStatus(true);  // Speichere, dass der Login übersprungen wurde
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()), // Navigiere zur MyHomePage
    );
  }

  // Funktion zum Simulieren eines Logins
  Future<void> _login() async {
    // Simuliere hier die Login-Logik (API-Aufruf oder ähnliches)
    if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      await _saveLoginStatus(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()), // Navigiere zur MyHomePage
      );
    } else {
      // Zeige eine Fehlermeldung
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Benutzername und Passwort eingeben')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Benutzername'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _skipLogin,
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
