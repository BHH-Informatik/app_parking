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

  // Methode zum Login
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/auth/login'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token']; // Rückgabe des Access Tokens
    } else {
      throw Exception('Login fehlgeschlagen. Statuscode: ${response.statusCode}');
    }
  }

  // Beispiel: Methode zum Abrufen der Parkplätze für ein bestimmtes Datum
  Future<List<dynamic>> fetchParkingLots(String date) async {
    // Sehr schöner code sage ich, aber das muss so
    var headers;
    try {
      headers = await _getHeaders();
    } catch (e) {
      headers = {'Content-Type': 'application/json',
    'Accept': 'application/json',};
    }


    final response = await http.get(
      Uri.parse('$BASE_URL/parking_lots/$date'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['parking_lots'];
    } else {
      throw Exception('Fehler beim Laden der Parkplätze. Statuscode: ${response.statusCode}');
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
      throw Exception('Fehler beim Buchen des Parkplatzes. Statuscode: ${response.statusCode}');
    }
  }

  // Methode zum AUTOMATISCHEN Buchen eines Parkplatzes
  Future<void> autoBookParkingLot({
    required String bookingDate,
    String? startTime,
    String? endTime,
  }) async {
    final headers = await _getHeaders();

    // Erstelle die Buchungsdaten
    final bookingData = {
      "booking_date": bookingDate,
      if (startTime != null) "start_time": startTime,
      if (endTime != null) "end_time": endTime,
    };

    final response = await http.post(
      Uri.parse('$BASE_URL/booking/autobook'),
      headers: headers,
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Fehler beim automatischen Buchen des Parkplatzes. Statuscode: ${response.statusCode}');
    }
  }

  // Methode zum Abrufen der Buchungen des Benutzers
  Future<List<dynamic>> fetchUserBookings() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$BASE_URL/user/bookings'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['bookings']; // Rückgabe der Buchungen
    } else if (response.statusCode == 404) {
      throw Exception('Keine Buchungen gefunden');
    } else {
      throw Exception('Fehler beim Abrufen der Buchungen. Statuscode: ${response.statusCode}');
    }
  }

  // Methode zum Stornieren einer Buchung
  Future<void> cancelBooking(String? bookingId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$BASE_URL/booking/$bookingId'), // Endpunkt zum Stornieren
      headers: headers,
    );

    if (response.statusCode == 200) {
      return; // Erfolg, keine spezielle Rückgabe nötig
    } else {
      throw Exception('Fehler beim Stornieren der Buchung. Statuscode: ${response.statusCode}');
    }
  }

  // Methode zum Senden des Feedbacks
  Future<void> sendFeedback({
    required String subject,
    required String message,
  }) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$BASE_URL/message/send'),
      headers: headers,
      body: jsonEncode({
        "subject": subject,
        "message": message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Fehler beim Senden des Feedbacks. Statuscode: ${response.statusCode}');
    }
  }

}
