import 'package:flutter/material.dart';
import '../../models/todo_task_model.dart';
import '../../widgets/todo_module/task_actions.dart';

class TaskDetail extends StatefulWidget {
  final ToDoTaskModel? task;

  const TaskDetail({super.key, required this.task});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  final List<String> actions = [
    'Mark as Important',
    'Add to My Day',
    'Repeat',
    'Move to List',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
        actions: [Icon(Icons.delete_outline, color: Colors.white, size: 27.0)],
        actionsPadding: EdgeInsets.only(right: 15.0),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.radio_button_unchecked,
                color: Color(0xFFA09CB0),
                size: 30.0,
              ),
              title: Text(
                widget.task?.name ??
                    "Add Task Name", //if task is not null, get the name otherwise show placeholder text
                style: TextStyle(
                  color: widget.task == null
                      ? Color(0xFF999999)
                      : Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                  fontSize: 22.0,
                ),
              ),
            ),
            Divider(
              color: Color(0xFFF3F4F6),
              indent: 8.0,
              endIndent: 8.0,
              thickness: 1.0,
            ),
            ...actions.map((action) => TaskActions(actionName: action)),
            //If you just put the .map() inside a Column, you would have an iterable inside a list, which would cause an error. The ... "unpacks" your newly created list so that each widget sits individually inside the parent.
          ],
        ),
      ),
    );
  }
}
