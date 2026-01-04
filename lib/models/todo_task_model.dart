class ToDoTaskModel {
  final String id;
  String name;
  int completionStatus; //0 for incomplete, 1 for complete
  String? notes;
  String listId;
  bool isImportant;
  bool isMyDay;
  bool repeat;

  ToDoTaskModel({
    required this.id,
    required this.listId,
    required this.name,
    required this.completionStatus,
    this.isImportant = false,
    this.isMyDay = false,
    this.notes,
    this.repeat = false,
  });

  // Convert Firestore document to ToDoTaskModel
  factory ToDoTaskModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ToDoTaskModel(
      id: docId,
      name: data['taskName'] ?? '',
      completionStatus: data['completionStatus'] ?? 0,
      notes: data['notes'],
      listId: data['listId'],
      isImportant: data['isImportant'] ?? false,
      isMyDay: data['isMyDay'] ?? false,
      repeat: data['repeat'] ?? false,
    );
  }
}
