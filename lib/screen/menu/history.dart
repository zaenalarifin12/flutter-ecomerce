import 'package:flutter/material.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

@override
void initState() { 
  super.initState();
  print("history");
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("History"),),
    );
  }
}