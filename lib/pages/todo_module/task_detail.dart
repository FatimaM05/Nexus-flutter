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
  bool isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task?.name ?? "");
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      isEditing = true;
    });
    _focusNode.requestFocus();
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      _textController.text = widget.task?.name ?? '';
    });
    _focusNode.unfocus();
  }

  void _saveTask() {
    setState(() {
      isEditing = false;
      widget.task?.name = _textController.text;
      //Update the task in the db
    });
    _focusNode.unfocus();
  }

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
              leading: IconButton(
                icon: Icon(
                  Icons.radio_button_unchecked,
                  color: Color(0xFFA09CB0),
                  size: 30.0,
                ),
                onPressed: () {},
              ),
              title: isEditing
                  ? TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                        fontSize: 22.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add Task Name',
                        hintStyle: TextStyle(color: Color(0xFF999999)),
                      ),
                      onSubmitted: (value) => _saveTask(),
                    )
                  : GestureDetector(
                      onTap: _startEditing,
                      child: Text(
                        _textController.text.isEmpty
                            ? "Add Task Name"
                            : _textController.text,
                        style: TextStyle(
                          color: _textController.text.isEmpty
                              ? Color(0xFF999999)
                              : Color(0xFF333333),
                          fontWeight: FontWeight.w500,
                          fontSize: 22.0,
                        ),
                      ),
                    ),
              trailing: isEditing
                  ? IconButton(
                      icon: Icon(Icons.close, color: Color(0xFF999999)),
                      onPressed: _cancelEditing,
                    )
                  : null,
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
