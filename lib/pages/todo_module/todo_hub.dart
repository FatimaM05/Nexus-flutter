import "package:flutter/material.dart";
import "../../widgets/todo_module/list_tile.dart";
//import "../../widgets/todo_module/floating_action_button.dart";
import "list_page.dart";
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ToDoList(listName: 'New List'),
            ),
          );
          // when we come back from the new list page, a list tile for that new list (using the list data returned by the page)will be added unless the user didnt create any list
          if (result != null && result is ToDoListModel) {
            setState(() {
              todoLists.add(result);
            });
          }
        },
      ),
    );
  }

  Widget _buildListsView() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),  //this hides the scrollbar
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
