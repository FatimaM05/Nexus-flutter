import 'package:flutter/material.dart';
import'../../models/todo_task_model.dart';

class TaskDetail extends StatelessWidget {
  final ToDoTaskModel task;
  const TaskDetail({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
      ),
      body: Center(
        child: Text('Details of ${task.name} will be shown here.'),
      ),
    );
  }
}