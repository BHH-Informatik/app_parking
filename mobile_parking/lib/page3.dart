import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Kontakt Seite
class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  
  //Funktion um Feedback zu Senden
  Future<void> _sendFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');
  
    setState(() {
      _isSending = true;
    });

    final subject = _subjectController.text;
    final message = _messageController.text;

    if (subject.isEmpty || message.isEmpty) {
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Titel und Beschreibung eingeben'))
      );
      return;
    }

    try{
      final response = await http.post(
        Uri.parse("https://parking.enten.dev/api/message/send"),
        headers: {
          "Authorization" : "Bearer $token",
          "Content-Type" : "application/json",
          "Accept" : "application/json",
        },
        body: jsonEncode(
          {
            "subject" : subject,
            "message" : message
          }
        )
      );
    
      if (response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ihr Feedback wurde gesendet.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Page3()),
        );

      } else {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senden des Feedbacks fehlgeschlagen. Bitte überprüfe deine Eingabe.')),
        );
      }
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ein Fehler ist aufgetreten.')),
      );
    }
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Beschreibung'),
            ),
            const SizedBox(height: 20),
            _isSending
                ? const CircularProgressIndicator()  // Ladeanzeige während des Senden
                : ElevatedButton(
              onPressed: _sendFeedback,
              child: const Text('Senden'),
            ),
          ],
        ),
      ),
    );
  }

}
