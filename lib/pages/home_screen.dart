import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(160, 156, 176, 100),
        title: const Text("Nexus App", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
