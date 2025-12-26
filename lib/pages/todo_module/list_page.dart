import "package:flutter/material.dart";
import '../../widgets/todo_module/task_tile.dart';
import '../../models/todo_task_model.dart';

class ToDoList extends StatefulWidget {
  final String listName;
  List<ToDoTaskModel> tasks = [
    ToDoTaskModel(id: 1, name: 'Get Groceries', completionStatus: 0),
    ToDoTaskModel(id: 1, name: 'Walk the dog', completionStatus: 1),
    ToDoTaskModel(id: 1, name: 'Cook dinner', completionStatus: 0),
    ToDoTaskModel(id: 1, name: 'play video game', completionStatus: 0),
    ToDoTaskModel(id: 1, name: 'read a book', completionStatus: 0),
    ToDoTaskModel(id: 1, name: 'assignment', completionStatus: 1),
    ToDoTaskModel(id: 1, name: 'water plants', completionStatus: 0),
    ToDoTaskModel(id: 1, name: 'clean house', completionStatus: 0),
    ToDoTaskModel(id: 1, name: 'laundry', completionStatus: 1),
    ToDoTaskModel(id: 1, name: 'meditate', completionStatus: 0),
    ToDoTaskModel(id: 1, name: 'home work', completionStatus: 1),
  ];
  ToDoList({super.key, required this.listName});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(160, 156, 176, 1),
      appBar: AppBar(
        title: Text("To Do List", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
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
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false), //this hides the scrollbar
                child: ListView.separated(
                  itemCount: widget.tasks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return TaskTile(task: widget.tasks[index]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
