import 'package:flutter/material.dart';
import './task_tile.dart';
import '../../models/todo_task_model.dart';

class CompletionStatus extends StatefulWidget {
  final List<ToDoTaskModel> completedTasks;
  const CompletionStatus(this.completedTasks, {super.key});

  @override
  State<CompletionStatus> createState() => _CompletionStatusState();
}

class _CompletionStatusState extends State<CompletionStatus> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        shape: Border(),
        showTrailingIcon: false,
        initiallyExpanded: true,
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        leading: Icon(
          isExpanded ? Icons.expand_more : Icons.chevron_right,
          color: Color(0xFF666666),
        ),
        title: Text('Completed (${widget.completedTasks.length})', style: TextStyle(color: Color(0xFF666666))),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(
          top: 5.0,
          left: 2.0,
          right: 2.0,
        ), //adds padding around all children as a group (top padding will add only before the first child)
        children: widget.completedTasks
            .map(
              (task) => Padding(
                //the padding widget will add padding around each individual task tile creating spacing between tasks
                padding: EdgeInsets.only(bottom: 8.0),
                child: TaskTile(task: task, listId: task.listId),
              ),
            )
            .toList(),
      );
  }
}
