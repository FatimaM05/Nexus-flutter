import "package:flutter/material.dart";
import "../../widgets/todo_module/list_tile.dart";
import "./list_page.dart";
import "../../widgets/custom_search_bar.dart";
import '../../models/todo_list_model.dart';
import '../../models/todo_task_model.dart';
import '../../widgets/todo_module/task_tile.dart';
import '../../services/todo_list_services.dart';
import 'dart:async';

class ToDoHub extends StatefulWidget {
  const ToDoHub({super.key});

  @override
  State<ToDoHub> createState() => _ToDoHubState();
}

class _ToDoHubState extends State<ToDoHub> {
  String searchQuery = '';
  List<ToDoListModel> todoLists = [];
  final ToDoListService _listService = ToDoListService();
  bool isLoading = true;
  StreamSubscription<List<ToDoListModel>>? _listsSubscription;

  List<ToDoTaskModel> filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  @override
  void dispose() {
    _listsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadLists() async {
    try {
      setState(() {
        isLoading = true;
      });

      _listsSubscription = _listService.listenToLists().listen(
        (lists) {
          setState(() {
            todoLists = lists;
            isLoading = false;
          });
        },
        onError: (error) {
          print('Error listening to lists: $error');
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to load lists')));
          }
        },
      );
    } catch (e) {
      print('Error loading lists: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(160, 156, 176, 1),
      body:
          //Main Body
          SafeArea(
            child: SizedBox.expand(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Container
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 8.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF3F4F6)),
                        ),
                      ),
                      child: CustomSearchBar(
                        onSearch: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        hint: 'Search Tasks',
                      ),
                    ),

                    SizedBox(height: 15.0),

                    // Lists Container
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 0.0,
                          horizontal: 8.0,
                        ),
                        child: searchQuery.isEmpty
                            ? _buildListsView()
                            : _buildSearchResults(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      // New List Button
      floatingActionButton: FloatingActionButton(
        tooltip: "New List",
        child: Icon(Icons.add),
        onPressed: () {
          _showNewListDialog(context);
        },
      ),
    );
  }

  void _showNewListDialog(BuildContext context) {
    final TextEditingController listNameController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Color.fromARGB(255, 148, 140, 179),
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Text(
                'New List',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
              content: TextField(
                controller: listNameController,
                focusNode: focusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter list name',
                  hintStyle: TextStyle(color: Color(0xFFA09CB0)),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF999999)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFA09CB0), width: 1),
                  ),
                ),
                onChanged: (value) {
                  setDialogState(
                    () {},
                  ); // Rebuild dialog to enable/disable button
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _createNewList(context, value);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    focusNode.dispose();
                    listNameController.dispose();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                ),
                TextButton(
                  onPressed: listNameController.text.trim().isEmpty
                      ? null
                      : () {
                          _createNewList(context, listNameController.text);
                          focusNode.dispose();
                          listNameController.dispose();
                        },
                  child: Text(
                    'Create List',
                    style: TextStyle(
                      color: listNameController.text.trim().isEmpty
                          ? Color.fromARGB(255, 189, 188, 188)
                          : Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createNewList(BuildContext context, String listName) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,  // this means the user can't dismiss the dialog box showing the indicator
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // calling the firestore function
      final ToDoListModel newList = await _listService.createNewList(listName.trim());

      print('List created with ID: ${newList.id}');

      // Close loading dialog
      Navigator.pop(context);

      // Close the create list dialog
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ToDoListPage(list: newList),
        ),
      );
    } catch (e) {
      print('Error creating list: $e');

      // Close loading dialog if it's open
      Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create list. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildListsView() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (todoLists.isEmpty) {
      return Center(
        child: Text(
          'No lists found. Create one using the + button.',
          style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
        ),
      );
    }
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false), //this hides the scrollbar
      child: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(bottom: 15.0),
        itemCount: todoLists.length,
        separatorBuilder: (context, index) => SizedBox(
          height: 8.0,
        ), //this will add the sizedbox between the list items to add gap
        itemBuilder: (context, index) {
          return SingleListTile(
            list: todoLists[index],
            icon: todoLists[index].name == 'My Day'
                ? Icons.light_mode_outlined
                : todoLists[index].name == 'Important Tasks'
                ? Icons.star_outline
                : todoLists[index].name == 'All Tasks'
                ? Icons.access_time_outlined
                : Icons.format_list_bulleted,
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        padding: EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        itemCount: filteredTasks.length,
        separatorBuilder: (context, index) => SizedBox(height: 8),
        itemBuilder: (context, index) {
          return TaskTile(task: filteredTasks[index], listId: '');
        },
      ),
    );
  }
}
