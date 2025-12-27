import 'package:flutter/material.dart';
import '../../models/todo_task_model.dart';
import '../../pages/todo_module/task_detail.dart';

class TaskTile extends StatelessWidget {
  final ToDoTaskModel task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
              red: 0,
              green: 0,
              blue: 0,
            ),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0), //til'es internal padding; horizontal apdding will control space between the leading and border, and trailing and border
        horizontalTitleGap: 0,  //gap between the titles and the leading/trailing widgets. 
        leading: IconButton(
          icon: task.completionStatus == 0
              ? Icon(Icons.radio_button_unchecked, color: Color(0xFFA09CB0))
              : Icon(Icons.check_circle, color: Color(0xFF99A1AF)),
          tooltip: 'Mark as complete',
          onPressed: () {},
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetail(task: task)),
            );
          },
          child: Text(
            task.name,
            textAlign: TextAlign.left,
            style: task.completionStatus == 1
                ? TextStyle(
                    color: Color(0xFF999999),
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Color(0xFF999999),
                  )
                : TextStyle(
                    color: Color(0xFF333333),
                    decoration: TextDecoration.none,
                  ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: task.completionStatus == 1
                ? Color(0x96999999)
                : Color(0xFF99A1AF),
          ),
          tooltip: 'Delete Task',
          onPressed: () {},
        ),
      ),
    );
  }
}
