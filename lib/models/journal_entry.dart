import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
    };
  }

  // Create from Map (from Firestore)
  factory JournalEntry.fromMap(Map<String, dynamic> map, [String? id]) {
    final dynamic dateValue = map['date'];
    DateTime parsedDate;

    if (dateValue == null) {
      parsedDate = DateTime.now();
    } else if (dateValue is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is Timestamp) {
      parsedDate = dateValue.toDate();
    } else if (dateValue is String) {
      parsedDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return JournalEntry(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: parsedDate,
    );
  }

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }
}
