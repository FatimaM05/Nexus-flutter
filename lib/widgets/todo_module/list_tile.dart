import 'package:flutter/material.dart';
import '../../pages/todo_module/list_page.dart';

class SingleListTile extends StatelessWidget {
  final String title;
  final String numberOfTasks;
  final IconData icon;

  const SingleListTile({
    super.key,
    required this.title,
    required this.numberOfTasks,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Color(0xFFA09CB0), width: 1.0),
      ),
      child: ListTile(
        leading: Icon(icon, size: 23.0, weight: 10.0, color: Color(0xFFA09CB0)),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              numberOfTasks,
              style: TextStyle(fontSize: 16, color: Color(0xFF999999)),
            ),
            SizedBox(width: 3.0),
            Icon(Icons.chevron_right, color: Color(0xFF99A1AF), size: 23.0),
          ],
        ),
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 3.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ToDoList(listName: title)),
          );
        },
      ),
    );
  }
}
