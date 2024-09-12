import 'package:flutter/material.dart';

enum FeedbackTyp {
  delete(color: Color.fromARGB(255, 252, 108, 92), title: 'Löschung'),
  broken(color: Color.fromARGB(255,255,204, 151) , title: 'Defekt'),
  other(color: Colors.green, title: 'Anderweitig');

  const FeedbackTyp({ required this.color, required this.title });

  final Color color;
  final String title;
}

class Feedbacks {

  const Feedbacks({ required this.title, required this.description, required this.feedbackType });

  final String title;
  final String description;
  final FeedbackTyp feedbackType;

}