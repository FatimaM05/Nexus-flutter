import "package:flutter/material.dart";

class ToDoList extends StatelessWidget {
  final String listName;
  const ToDoList({super.key, required this.listName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(160, 156, 176, 1),
      appBar: AppBar(
        title: Text("To Do List", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),

        child: Text("This is the ${listName} To Do List."),
      ),
    );
  }
}
