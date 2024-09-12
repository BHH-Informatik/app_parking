import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Definiere die Base URL als Konstante
  static const String BASE_URL = 'https://parking.enten.dev/api';

  // Beispiel: Methode zum Abrufen der Parkplätze für ein bestimmtes Datum
  Future<List<dynamic>> fetchParkingLots(String date) async {
    // Hole den Access Token aus shared_preferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Kein Zugriffstoken gefunden. Bitte loggen Sie sich erneut ein.');
    }

    // Führe die API-Anfrage mit dem Bearer-Token durch
    final response = await http.get(
      Uri.parse('$BASE_URL/parking_lots/$date'),
      headers: {
        'Authorization': 'Bearer $token',  // Füge den Bearer-Token hinzu
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Verarbeite die API-Antwort und gebe die Parkplätze zurück
      return jsonDecode(response.body)['parking_lots'];
    } else {
      throw Exception('Fehler beim Laden der Parkplätze: ${response.statusCode}');
    }
  }
}
