import 'package:flutter/material.dart';

class TaskActions extends StatelessWidget {
  final String actionName;

  const TaskActions({super.key, required this.actionName});

  IconData _getIcon() {
    switch (actionName) {
      case 'Mark as Important':
        return Icons.star_outline;
      case 'Repeat':
        return Icons.repeat;
      case 'Move to List':
        return Icons.summarize_outlined;
      case 'Add to My Day':
        return Icons.light_mode_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getIcon(), color: Color(0xFF99A1AF), size: 27.0),
      title: Text(actionName),
      contentPadding: EdgeInsets.only(left: 30, top: 4, bottom: 4),
    );
  }
}
