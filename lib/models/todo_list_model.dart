class ToDoListModel {
  final String id;
  String name;
  int numberOfTasks;
  final bool isDefault;

  ToDoListModel({
    required this.id,
    required this.name,
    required this.numberOfTasks,
    this.isDefault = false,
  });
}
