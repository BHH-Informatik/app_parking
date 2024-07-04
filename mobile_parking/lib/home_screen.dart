import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<TableData>> tableData;

  @override
  void initState() {
    super.initState();
    tableData = fetchTableData();
  }

  Future<List<TableData>> fetchTableData() async {
    final response = await http.get(Uri.parse('https://kapanke.net/capstone/table'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => TableData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Dynamic Table'),
      ),
      body: Center(
        child: FutureBuilder<List<TableData>>(
          future: tableData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else {
              return buildTable(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget buildTable(List<TableData> data) {
    return Table(
      border: TableBorder.all(),
      children: data.map((item) {
        return TableRow(
          children: [
            CustomTableCell(text: item.leftCell, textColor: Colors.white, backgroundColor: item.leftCellColor),
            CustomTableCell(text: item.rightCell, textColor: Colors.black, backgroundColor: item.rightCellColor),
          ],
        );
      }).toList(),
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

class TableData {
  final String leftCell;
  final String rightCell;
  final Color leftCellColor;
  final Color rightCellColor;

  TableData({
    required this.leftCell,
    required this.rightCell,
    required this.leftCellColor,
    required this.rightCellColor,
  });

  factory TableData.fromJson(Map<String, dynamic> json) {
    return TableData(
      leftCell: json['leftCell'],
      rightCell: json['rightCell'],
      leftCellColor: Color(int.parse(json['leftCellColor'].substring(1, 7), radix: 16) + 0xFF000000),
      rightCellColor: Color(int.parse(json['rightCellColor'].substring(1, 7), radix: 16) + 0xFF000000),
    );
  }
}
