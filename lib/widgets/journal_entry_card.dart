import 'package:flutter/material.dart';
import 'package:nexus/models/journal_entry.dart';

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Color.fromRGBO(200, 200, 200, 1),
          width: 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and date row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(51, 51, 51, 1),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(entry.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(153, 161, 175, 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Content preview
              Text(
                entry.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(102, 102, 102, 1),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Divider
              const Divider(
                height: 1,
                color: Color.fromRGBO(240, 240, 240, 1),
              ),
              const SizedBox(height: 8),
              // Tags (if any)
              if (entry.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: const Color.fromRGBO(200, 200, 200, 1),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(102, 102, 102, 1),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}