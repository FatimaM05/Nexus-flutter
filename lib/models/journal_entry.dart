class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.tags = const [],
  });

  // Convert to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.millisecondsSinceEpoch,
      'tags': tags,
    };
  }

  // Create from Map (from Firestore)
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}