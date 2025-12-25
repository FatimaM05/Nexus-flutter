import "package:flutter/material.dart";
import "../../widgets/todo_module/list_tile.dart";
import "../../widgets/todo_module/floating_action_button.dart";
import "list_page.dart";
import "../../widgets/custom_search_bar.dart";

class ToDoHub extends StatefulWidget {
  const ToDoHub({super.key});

  @override
  State<ToDoHub> createState() => _ToDoHubState();
}

class _ToDoHubState extends State<ToDoHub> {
  String searchQuery = '';

  //THE LISTSSSSSS
  List<String> todoLists = ['MyDay', 'All Tasks', 'Important Tasks'];

  // SEARCH RESULTSSSSS
  List<String> filteredTasks = [];

  //WRITE FILTER TASK FUNCTION HEREEEE (the one that will filter the tasks to show search results)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(160, 156, 176, 1),
      appBar: AppBar(
        title: Text("To Do Hub", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(160, 156, 176, 1),
      ),
      body:
          //Main Body
          SizedBox.expand(
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
                    child: SingleChildScrollView(
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

      // New List Button
      floatingActionButton: FloatingActionButton(
        tooltip: "New List",
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ToDoList(listName: 'New List')),
          );
        },
      ),
    );
  }

  Widget _buildListsView() {





    return SingleListTile(title:'My Day', numberOfTasks: '4', icon:Icons.light_mode_outlined);
  }

  Widget _buildSearchResults() {
    return Text('SEARCH RESULTSSSS');
  }
}
