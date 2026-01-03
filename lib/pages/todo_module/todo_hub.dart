import "package:flutter/material.dart";
import "../../widgets/todo_module/list_tile.dart";
import "./list_page.dart";
import "../../widgets/custom_search_bar.dart";
import '../../models/todo_list_model.dart';

class ToDoHub extends StatefulWidget {
  const ToDoHub({super.key});

  @override
  State<ToDoHub> createState() => _ToDoHubState();
}

class _ToDoHubState extends State<ToDoHub> {
  String searchQuery = '';
  //THE LISTSSSSSS
  List<ToDoListModel> todoLists = [];
  // SEARCH RESULTSSSSS
  List<String> filteredTasks = [];

  @override
  void initState() {
    super.initState();
    //temporary dummy data for lists to be displayed
    setState(() {
      todoLists = [
        ToDoListModel(id: 1, numberOfTasks: 4, name: 'My Day'),
        ToDoListModel(id: 2, numberOfTasks: 2, name: 'Important Tasks'),
        ToDoListModel(id: 3, numberOfTasks: 3, name: 'All Tasks'),
        ToDoListModel(id: 4, numberOfTasks: 0, name: 'Work'),
        ToDoListModel(id: 5, numberOfTasks: 1, name: 'Personal'),
        ToDoListModel(id: 6, numberOfTasks: 0, name: 'Work'),
        ToDoListModel(id: 7, numberOfTasks: 1, name: 'Personal'),
        ToDoListModel(id: 6, numberOfTasks: 0, name: 'Work'),
        ToDoListModel(id: 7, numberOfTasks: 1, name: 'Personal'),
        ToDoListModel(id: 6, numberOfTasks: 0, name: 'Work'),
        ToDoListModel(id: 7, numberOfTasks: 1, name: 'Personal'),
      ];
    });
    //call method for fetching list data
  }

  //function to get the lists' data from firebase and send to model ToDoListModel

  //WRITE FILTER TASK FUNCTION HEREEEE (the one that will filter the tasks to show search results)

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

  void _createNewList(BuildContext context, String listName) {
    // call Firebase function here to cretae a new list
    // then call the firebase function to get the list and add it to the todoLists list
    setState(() {
      todoLists.add(
        ToDoListModel(
          id: todoLists.length + 1,
          numberOfTasks: 0,
          name: listName,
        ),
      );
    });

    Navigator.pop(context); // Close dialog

    // Navigate to the new list page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ToDoListPage(listName: listName, isDefault: false),
      ),
    );
  }

  Widget _buildListsView() {
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
            title: todoLists[index].name,
            numberOfTasks: todoLists[index].numberOfTasks.toString(),
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
    return Text('SEARCH RESULTSSSS');
  }
}
