import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Home Screen oder so ähnlich',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 30), // Abstand zwischen Text und Tabelle
          Table(
            // border: TableBorder.all(),
            children: const [
              TableRow(
                children: [
                  CustomTableCell(text: 'P1', textColor: Colors.white, backgroundColor: Colors.blue),
                  CustomTableCell(text: 'P2', textColor: Colors.black, backgroundColor: Colors.yellow),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P3', textColor: Colors.white, backgroundColor: Colors.green),
                  CustomTableCell(text: 'P4', textColor: Colors.black, backgroundColor: Colors.orange),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P5', textColor: Colors.white, backgroundColor: Colors.red),
                  CustomTableCell(text: 'P6', textColor: Colors.black, backgroundColor: Colors.purple),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P7', textColor: Colors.white, backgroundColor: Colors.teal),
                  CustomTableCell(text: 'P8', textColor: Colors.black, backgroundColor: Colors.pink),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P9', textColor: Colors.white, backgroundColor: Colors.brown),
                  CustomTableCell(text: 'P10', textColor: Colors.black, backgroundColor: Colors.cyan),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P11', textColor: Colors.white, backgroundColor: Colors.indigo),
                  CustomTableCell(text: 'P12', textColor: Colors.black, backgroundColor: Colors.lime),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P13', textColor: Colors.white, backgroundColor: Colors.grey),
                  CustomTableCell(text: 'P14', textColor: Colors.black, backgroundColor: Colors.amber),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P15', textColor: Colors.white, backgroundColor: Colors.lightGreen),
                  CustomTableCell(text: 'P16', textColor: Colors.black, backgroundColor: Colors.deepOrange),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P17', textColor: Colors.white, backgroundColor: Colors.lightBlue),
                  CustomTableCell(text: 'P18', textColor: Colors.black, backgroundColor: Colors.deepPurple),
                ],
              ),
              TableRow(
                children: [
                  CustomTableCell(text: 'P19', textColor: Colors.white, backgroundColor: Colors.blueGrey),
                  CustomTableCell(text: 'P20', textColor: Colors.black, backgroundColor: Colors.lightGreenAccent),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomTableCell extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;

  const CustomTableCell({
    super.key,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: backgroundColor,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
