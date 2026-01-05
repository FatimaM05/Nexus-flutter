import "package:flutter/material.dart";
import '../../widgets/todo_module/task_tile.dart';
import '../../models/todo_task_model.dart';
import '../../widgets/todo_module/completion_status.dart';
import '../todo_module/task_detail.dart';
import '../../models/todo_list_model.dart';
import '../../services/todo_list_services.dart';
import 'dart:async';

class ToDoListPage extends StatefulWidget {
  final ToDoListModel list;

  ToDoListPage({super.key, required this.list});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  List<ToDoTaskModel> allTasks = [];
  List<ToDoTaskModel> completedTasks = [];
  List<ToDoTaskModel> pendingTasks = [];

  bool isEditing = false;
  bool isLoading = true;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  final ToDoListService _listService = ToDoListService();
  StreamSubscription<List<ToDoTaskModel>>? _tasksSubscription;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.list.name);
    _focusNode = FocusNode();
    _loadTasks();
    //filterTasks();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        isLoading = true;
      });
      // Listen to real-time task updates
      _tasksSubscription = _listService
          .fetchAllTasks(widget.list.id)
          .listen(
            (tasks) {
              setState(() {
                allTasks = tasks;
                filterTasks();
                isLoading = false;
              });
            },
            onError: (error) {
              print('Error listening to tasks: $error');
              setState(() {
                isLoading = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed to load tasks')));
              }
            },
          );
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        isLoading = false;
      });
    }
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
      _textController.text = widget.list.name;
    });
    _focusNode.unfocus();
  }

  void _updateListName() async {
    // Don't update if name is empty or unchanged
    if (_textController.text.trim().isEmpty) {
      _cancelEditing();
      return;
    }

    if (_textController.text.trim() == widget.list.name) {
      setState(() {
        isEditing = false;
      });
      _focusNode.unfocus();
      return;
    }

    try {
      // Update in database
      await _listService.updateListName(
        widget.list.id,
        _textController.text.trim(),
      );

      setState(() {
        widget.list.name = _textController.text.trim();
        isEditing = false;
      });
    } catch (e) {
      print('Error updating list name: $e');

      // Revert to original name
      setState(() {
        _textController.text = widget.list.name;
        isEditing = false;
      });
    }

    _focusNode.unfocus();
  }

  void filterTasks() {
    completedTasks = [];
    pendingTasks = [];

    for (var task in allTasks) {
      if (task.completionStatus == 1) {
        completedTasks.add(task);
      } else {
        pendingTasks.add(task);
      }
    }
  }

  void _deleteList() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Delete the list from Firestore
      await _listService.deleteList(widget.list.id);

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Go back to todo hub
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error deleting list: $e');

      // Close loading dialog if open
      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete list. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.list.isDefault
            ? Text(
                widget.list.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 22.0,
                ),
              )
            : isEditing
            ? TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 22.0,
                ),
                decoration: InputDecoration(border: InputBorder.none),
                onSubmitted: (value) => _updateListName(),
              )
            : GestureDetector(
                onDoubleTap: _startEditing,
                child: Text(
                  _textController.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 22.0,
                  ),
                ),
              ),
        actions: widget.list.isDefault
            ? []
            : isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: _cancelEditing,
                ),
              ]
            : [
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _deleteList,
                ),
              ],
        actionsPadding: EdgeInsets.only(right: 20.0),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: allTasks.isEmpty
                    ? Center(
                        child: Text(
                          "No tasks yet. Add tasks using the + button.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF999999),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          right: 8.0,
                          left: 8.0,
                        ),
                        itemCount:
                            pendingTasks.length +
                            (completedTasks.isNotEmpty ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index < pendingTasks.length) {
                            return TaskTile(
                              task: pendingTasks[index],
                              listId: widget.list.id,
                            );
                          } else {
                            return CompletionStatus(completedTasks);
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskDetail(task: null, listId: widget.list.id),
            ),
          );
        },
      ),
    );
  }
}
