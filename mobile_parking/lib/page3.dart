import 'package:flutter/material.dart';
import 'model/feedback.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Kontakt Seite
class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final _formGlobalKey = GlobalKey<FormState>();

  FeedbackTyp _selectedPriority = FeedbackTyp.other;
  String _title = '';
  String _description = '';

  final List<Feedbacks> feedback = [
  //   const Feedbacks(
  //       title: ' Alles blöd hier',
  //       description: 'Parkplatz kaputt grrrr',
  //       feedbackType: FeedbackTyp.broken),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesendete Anfragen'),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(child: FeedbackList(feedback: feedback)),
            Form(
              key: _formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Feedback Titel
                  TextFormField(
                      maxLength: 20,
                      decoration:
                          const InputDecoration(label: Text('Feedback Titel')),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Gib einen Titel ein.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value!;
                      }),

                  // Feedback Beschreibung
                  TextFormField(
                      maxLength: 90,
                      decoration: const InputDecoration(
                          label: Text('Feedback Beschreibung')),
                      validator: (v) {
                        if (v == null || v.isEmpty || v.length < 10) {
                          return 'Gib eine Beschreibung, die länger als 10 Zeichen lang ist ein.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _description = value!;
                      }),

                  // Feedback Typ
                  DropdownButtonFormField(
                    value: _selectedPriority,
                    decoration:
                        const InputDecoration(label: Text('Feedback Typ')),
                    items: FeedbackTyp.values.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.title));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),

                  // Button
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      if (_formGlobalKey.currentState!.validate()) {
                        _formGlobalKey.currentState!.save();
                        
                        // Hinzufügen 
                        setState(() {
                          feedback.add(Feedbacks(
                              title: _title,
                              description: _description,
                              feedbackType: _selectedPriority));
                        });

                        _formGlobalKey.currentState!.reset();
                        _selectedPriority = FeedbackTyp.other;
                      }   
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 252, 108, 92),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Hinzufügen'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FeedbackList extends StatefulWidget {
  const FeedbackList({required this.feedback, super.key});

  final List<Feedbacks> feedback;

  @override
  State<FeedbackList> createState() => _FeedbackListState();
}

class _FeedbackListState extends State<FeedbackList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.feedback.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: widget.feedback[index].feedbackType.color.withOpacity(0.7),
                ),
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.feedback[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(widget.feedback[index].description),
                          ]),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: widget.feedback[index].feedbackType.color,
                        ),
                        child: Text(widget.feedback[index].feedbackType.title),
                      ),
                    ])),
          );
        });
  }
}