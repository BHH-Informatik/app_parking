import 'package:flutter/material.dart';

enum FeedbackTyp {
  delete(color: Colors.red, title: 'Löschung'),
  broken(color: Colors.orange, title: 'Defekt'),
  wish(color: Colors.amber, title: 'Feature'),
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