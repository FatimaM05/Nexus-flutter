import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(160, 156, 176, 1),
          title: Text("Nexus App", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
