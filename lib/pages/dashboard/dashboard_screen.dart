import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/todo_list_services.dart';
import '../../models/todo_task_model.dart';
import '../../models/todo_list_model.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback goToTodo;
  final String username;
  const DashboardScreen({
    super.key,
    required this.goToTodo,
    required this.username,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  File? _highlightImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _journalController = TextEditingController();
  final ToDoListService _toDoListService = ToDoListService();

  //getting the id of 'My Day' list to fetch and display its tasks
  String? _myDayListId;
  List<ToDoTaskModel> _todaysTasks = [];

  @override
  void initState() {
    super.initState();
    _loadMyDayTasks();
  }

  Future<void> _loadMyDayTasks() async {
    try {
      // Listen to lists to find "My Day" list ID
      _toDoListService.listenToLists().listen((lists) {
        final myDayList = lists.firstWhere(
          (list) => list.name == 'My Day',
          orElse: () => ToDoListModel(
            id: '',
            name: '',
            numberOfTasks: 0,
            isDefault: false,
          ),
        );

        if (myDayList.id.isNotEmpty && myDayList.id != _myDayListId) {
          setState(() {
            _myDayListId = myDayList.id;
          });

          // Now fetch tasks for this list
          _toDoListService.fetchAllTasks(myDayList.id).listen((tasks) {
            setState(() {
              _todaysTasks = tasks
                  .where((task) => task.completionStatus == 0)
                  .take(3)
                  .toList();
            });
          });
        }
      });
    } catch (e) {
      print('Error loading My Day tasks: $e');
    }
  }

  Future<void> _pickHighlightImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _highlightImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning, ${widget.username}",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 24),
            _buildCard(
              title: "Today's Tasks",
              trailing: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFA5A5BC),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_todaysTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "No tasks for today",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ..._todaysTasks.map((task) => _taskItem(task.name)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: widget.goToTodo,
                    child: Text(
                      _todaysTasks.isEmpty ? 'Add Tasks' : "See more",
                      style: const TextStyle(
                        color: Color(0xFFA5A5BC),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: "Today's Journal",
              trailing: const Text(
                "Dec 8",
                style: TextStyle(color: Colors.grey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Help me guys im done with university",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _journalController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: "What’s on your mind?",
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: "Today's Highlight",
              child: GestureDetector(
                onTap: _pickHighlightImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _highlightImage == null
                      ? const Center(
                          child: Icon(Icons.add, size: 40, color: Colors.grey),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _highlightImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _taskItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA5A5BC), width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
