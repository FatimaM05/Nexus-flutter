import 'package:flutter/material.dart';
import '../../pages/todo_module/list_page.dart';
import '../../models/todo_list_model.dart';

class SingleListTile extends StatelessWidget {
  // final String title;
  // final String numberOfTasks;
  final IconData icon;
  //final List<String> defaultLists = ['My Day', 'Important Tasks', 'All Tasks'];
  final ToDoListModel list;
  SingleListTile({
    super.key,
    required this.list,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Color(0xFFA09CB0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
              red: 0,
              green: 0,
              blue: 0,
            ),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, size: 23.0, weight: 10.0, color: Color(0xFFA09CB0)),
        title: Text(
          list.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0XFF333333),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              list.numberOfTasks.toString(),
              style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
            ),
            SizedBox(width: 3.0),
            Icon(Icons.chevron_right, color: Color(0xFF99A1AF), size: 23.0),
          ],
        ),
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
        onTap: () {
          print('Navigating to list: ${list.name}, listId: ${list.id}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ToDoListPage(
                list: list,
              ),
            ),
          );
        },
      ),
    );
  }
}
