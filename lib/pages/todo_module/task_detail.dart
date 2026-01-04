import 'package:flutter/material.dart';
import '../../models/todo_task_model.dart';
import '../../widgets/todo_module/task_actions.dart';
import '../../services/todo_tasks_services.dart';

class TaskDetail extends StatefulWidget {
  final ToDoTaskModel? task;
  final String? listId;

  const TaskDetail({super.key, required this.task, required this.listId});

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
  bool isEditingTaskName = false;
  bool isEditingNotes = false;
  bool _isSaving = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;
  late TextEditingController? _notesController;
  late FocusNode _notesFocusNode;
  String _originalNotes = '';

  final ToDoTaskService _taskService = ToDoTaskService();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.task?.name ?? "");
    _focusNode = FocusNode();

    // Safe initialization
    String initialNotes = '';
    if (widget.task != null && widget.task!.notes != null) {
      initialNotes = widget.task!.notes!;
    }

    _notesController = TextEditingController(text: initialNotes);
    _notesFocusNode = FocusNode();
    _originalNotes = initialNotes;

    _notesFocusNode.addListener(() {
      if (_notesFocusNode.hasFocus && !isEditingNotes) {
        setState(() {
          isEditingNotes = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _notesController?.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _saveTask() async {
    // Don't save if task name is empty
    if (_textController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.task == null) {
        // Creating a new task
        if (widget.listId == null) {
          throw Exception('List ID is required to create a task');
        }

        final newTask = await _taskService.createTask(
          listId: widget.listId!,
          taskName: _textController.text.trim(),
          notes: _notesController?.text.trim(),
        );

        print('Task created: ${newTask.id}');

        if (mounted) {
          // Go back to the list page
          Navigator.pop(context);
        }
      } else {
        // Updating existing task's name
        await _taskService.updateTaskName(
          widget.task!.id,
          _textController.text.trim(),
        );

        setState(() {
          widget.task!.name = _textController.text.trim();
          isEditingTaskName = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task updated successfully!'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        print('Task name updated: ${widget.task!.id}');
      }
    } catch (e) {
      print('Error saving task: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save task')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
    _focusNode.unfocus();
  }

  void _saveNotes() async {
    if (_notesController == null) return;

    try {
      if (widget.task != null) {
        // Update notes in database
        await _taskService.updateTaskNotes(
          widget.task!.id,
          _notesController!.text.trim().isEmpty
              ? null
              : _notesController!.text.trim(),
        );

        setState(() {
          isEditingNotes = false;
          widget.task!.notes = _notesController!.text.trim().isEmpty
              ? null
              : _notesController!.text.trim();
          _originalNotes = _notesController!.text;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notes updated successfully!'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        print('Task notes updated: ${widget.task!.id}');
      } else {
        // For new tasks, just update the local state
        setState(() {
          isEditingNotes = false;
          _originalNotes = _notesController!.text;
        });
      }
    } catch (e) {
      print('Error saving notes: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save notes')));
      }
    }
    _notesFocusNode.unfocus();
  }

  void _startEditing() {
    setState(() {
      isEditingTaskName = true;
    });
    _focusNode.requestFocus();
  }

  void _cancelEditing() {
    setState(() {
      isEditingTaskName = false;
      _textController.text = widget.task?.name ?? '';
    });
    _focusNode.unfocus();
  }

  void _cancelNotes() {
    if (_notesController == null) return;

    setState(() {
      isEditingNotes = false;
      if (_notesController != null) {
        _notesController!.text = _originalNotes;
      }
    });
    _notesFocusNode.unfocus();
  }

  void _toggleTaskCompletion() async {
    if (widget.task == null) return;

    try {
      // Toggle completion status (0 -> 1 or 1 -> 0)
      final newStatus = widget.task!.completionStatus == 0 ? 1 : 0;

      // Update in database
      await _taskService.updateTaskStatus(widget.task!.id, newStatus);

      // Update local state
      setState(() {
        widget.task!.completionStatus = newStatus;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 1 ? 'Task completed!' : 'Task marked as incomplete',
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }

      print('Task completion status updated: ${widget.task!.id}');
    } catch (e) {
      print('Error toggling task completion: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update task status')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.white, size: 27.0),
              onPressed: () {
                // TODO: Delete task
              },
            ),
          if (widget.task == null && !_isSaving)
            IconButton(
              icon: Icon(Icons.check, color: Colors.white, size: 27.0),
              onPressed: _saveTask,
            ),
          if (_isSaving)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: widget.task == null
                    ? SizedBox(width: 48) // Placeholder for new tasks
                    : IconButton(
                        icon: Icon(
                          Icons.radio_button_unchecked,
                          color: Color(0xFFA09CB0),
                          size: 30.0,
                        ),
                        onPressed: _toggleTaskCompletion,
                      ),
                title: widget.task == null || isEditingTaskName
                    ? TextField(
                        controller: _textController,
                        autofocus: widget.task == null,
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
                trailing:
                    (widget.task == null ||
                        isEditingTaskName) // Changed this line
                    ? IconButton(
                        icon: Icon(Icons.close, color: Color(0xFF999999)),
                        onPressed: widget.task == null
                            ? () =>
                                  Navigator.pop(
                                    context,
                                  ) // Close the page for new tasks
                            : _cancelEditing, // Cancel editing for existing tasks
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
              Divider(
                color: Color(0xFFF3F4F6),
                indent: 8.0,
                endIndent: 8.0,
                thickness: 1.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isEditingNotes)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: Color(0xFF999999)),
                            onPressed: _cancelNotes,
                          ),
                          IconButton(
                            icon: Icon(Icons.check, color: Color(0xFF999999)),
                            onPressed: _saveNotes,
                          ),
                        ],
                      ),
                    TextField(
                      controller: _notesController,
                      focusNode: _notesFocusNode,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Add notes',
                        hintStyle: TextStyle(color: Color(0xFF999999)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Color(0xFFA09CB0)),
                        ),
                      ),
                      onSubmitted: (value) => _saveNotes(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
