import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Definiere die Base URL als Konstante
  static const String BASE_URL = 'https://parking.enten.dev/api';

  // Methode zum Erstellen der Header (mit Authorization)
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Kein Zugriffstoken gefunden. Bitte loggen Sie sich erneut ein.');
    }

    // Erstelle die Header
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Beispiel: Methode zum Abrufen der Parkplätze für ein bestimmtes Datum
  Future<List<dynamic>> fetchParkingLots(String date) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$BASE_URL/parking_lots/$date'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['parking_lots'];
    } else {
      throw Exception('Fehler beim Laden der Parkplätze: ${response.statusCode}');
    }
  }

  // Methode zum Buchen eines Parkplatzes
  Future<void> bookParkingLot({
    required int parkingLotId,
    required String bookingDate,
    String? startTime,
    String? endTime,
  }) async {
    final headers = await _getHeaders();

    // Erstelle die Buchungsdaten
    final bookingData = {
      "parking_lot_id": parkingLotId,
      "booking_date": bookingDate,
      if (startTime != null) "start_time": startTime,
      if (endTime != null) "end_time": endTime,
    };

    final response = await http.post(
      Uri.parse('$BASE_URL/booking/reserve'),
      headers: headers,
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim Buchen des Parkplatzes: ${response.statusCode}');
    }
  }
}
