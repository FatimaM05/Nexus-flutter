import 'package:flutter/material.dart';
import './todo_module/todo_hub.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(160, 156, 176, 100),
        title: const Text("Nexus App", style: TextStyle(color: Colors.white)),
      ),
      body: ToDoButton(),
    );
  }
}

class ToDoButton extends StatelessWidget {
  const ToDoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
          child: const Text("Todo Hub Page"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToDoHub()),
            );
          },
        ),
      );
  }
}

