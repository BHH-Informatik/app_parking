import 'package:flutter/material.dart';
import 'package:mobile_parking/service/api_service.dart'; // ApiService importieren


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
  final ApiService apiService = ApiService(); // Instanz des ApiService

  // Funktion um Feedback zu senden
  Future<void> _sendFeedback() async {
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
        const SnackBar(content: Text('Bitte Titel und Beschreibung eingeben')),
      );
      return;
    }

    try {
      await apiService.sendFeedback(subject: subject, message: message); // Verwende ApiService

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ihr Feedback wurde gesendet.')),
      );

      // Formular zurücksetzen nach erfolgreichem Senden
      _subjectController.clear();
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senden des Feedbacks fehlgeschlagen. Bitte überprüfe deine Eingabe.')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback', style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary
        ),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
