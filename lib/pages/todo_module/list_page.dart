import "package:flutter/material.dart";
import '../../widgets/todo_module/task_tile.dart';
import '../../models/todo_task_model.dart';
import '../../widgets/todo_module/completion_status.dart';
import '../todo_module/task_detail.dart';

class ToDoList extends StatefulWidget {
  final String listName;

  const ToDoList({super.key, required this.listName});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<ToDoTaskModel> allTasks = [
    ToDoTaskModel(id: 1, name: 'Get Groceries', completionStatus: 0),
    ToDoTaskModel(id: 2, name: 'Walk the dog', completionStatus: 1),
    ToDoTaskModel(id: 3, name: 'Cook dinner', completionStatus: 0),
    ToDoTaskModel(id: 4, name: 'play video game', completionStatus: 0),
    ToDoTaskModel(id: 5, name: 'read a book', completionStatus: 0),
    ToDoTaskModel(id: 6, name: 'assignment', completionStatus: 1),
    ToDoTaskModel(id: 7, name: 'water plants', completionStatus: 0),
    ToDoTaskModel(id: 8, name: 'clean house', completionStatus: 0),
    ToDoTaskModel(id: 9, name: 'laundry', completionStatus: 1),
    ToDoTaskModel(id: 10, name: 'meditate', completionStatus: 0),
    ToDoTaskModel(id: 11, name: 'home work', completionStatus: 1),
  ];
  List<ToDoTaskModel> completedTasks = [];
  List<ToDoTaskModel> pendingTasks = [];

  //method to get the tasks of this list from the database

  @override
  void initState() {
    super.initState();
    filterTasks();
  }

  void filterTasks() {
    // initializing them to empty lists to avoid duplicate tasks in them when the method is called after the first time
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.listName == 'New List' ? "New List" : "To Do List",
          style: TextStyle(color: Colors.white),
        ),
        actions: widget.listName == 'New List' ? [Icon(Icons.done)] : null,
        actionsPadding: widget.listName == 'New List'
            ? EdgeInsets.only(right: 20.0)
            : EdgeInsets.zero,
      ),
      body: SafeArea(
        child: widget.listName == 'New List'
            ? Container(
                padding: EdgeInsets.all(15.0),
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    "No tasks yet. Add tasks using the + button.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
                  ),
                ),
              )
            : Column(
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
                      child: ListView.separated(
                        padding: EdgeInsets.only(
                          top: 8.0,
                          right: 8.0,
                          left: 8.0,
                        ), //the top padding will create a visual separation between the container's edge and the first pending task
                        //we're going to have one ListView as our body, the last item in that listview will be the collapsible section, all others will be our incomplete tasks, which means our itemCount depends on the fact whether we have completed tasks or not (cuz collapsible section will only show when there are completed tasks), hence the ternary operator in the itemCount value
                        itemCount:
                            pendingTasks.length +
                            (completedTasks.isNotEmpty ? 1 : 0),
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          // If pendingTasks has 5 items (indices 0-4), then:
                          // - Indices 0-4: show pending tasks (index < pendingTasks.length)
                          // - Index 5 (= pendingTasks.length): show completed section
                          // The completed section always appears at index = pendingTasks.length
                          if (index < pendingTasks.length) {
                            return TaskTile(task: pendingTasks[index]);
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
                  TaskDetail(task: null),
            ),
          );
        },
      ),
    );
  }
}
