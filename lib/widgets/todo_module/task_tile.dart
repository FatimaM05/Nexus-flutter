import 'package:flutter/material.dart';
import '../../models/todo_task_model.dart';
import '../../pages/todo_module/task_detail.dart';
import '../../services/todo_tasks_services.dart';

class TaskTile extends StatefulWidget {
  final ToDoTaskModel task;
  final String listId;
  
  const TaskTile({super.key, required this.task, required this.listId});

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  final ToDoTaskService _taskService = ToDoTaskService();

  void _toggleTaskCompletion() async {
    try {
      // Toggle completion status
      final newStatus = widget.task.completionStatus == 0 ? 1 : 0;

      // Update in database
      await _taskService.updateTaskStatus(widget.task.id, newStatus);
    } catch (e) {
      print('Error toggling task completion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            widget.task.completionStatus == 1
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: widget.task.completionStatus == 1
                ? Color(0x96999999)
                : Color(0xFFA09CB0),
            size: 27.0,
          ),
          onPressed: _toggleTaskCompletion,
        ),
        title: Text(
          widget.task.name,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: widget.task.completionStatus == 1
                ? Color(0xFF999999)
                : Color(0xFF333333),
            decoration: widget.task.completionStatus == 1
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Color(0xFF99A1AF),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetail(
                task: widget.task,
                listId: widget.listId,
              ),
            ),
          );
        },
      ),
    );
  }
}