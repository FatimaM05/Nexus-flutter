class ToDoTaskModel {
  final int id;
  String name;
  int completionStatus; //0 for incomplete, 1 for complete
  String? notes;

  ToDoTaskModel({
    required this.id,
    required this.name,
    required this.completionStatus,
    this.notes,
  });

  //method to convert firebase entries  into objects of this class

  //method to convert object of this class in a format that firebase can understand before storing
}
