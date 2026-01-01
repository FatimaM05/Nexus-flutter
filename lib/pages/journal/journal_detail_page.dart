import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/journal_entry.dart';
import 'package:nexus/pages/journal/new_entry_page.dart';

class JournalDetailPage extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Journal Entry',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromRGBO(160, 156, 176, 1),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewEntryPage(existingEntry: entry),
                ),
              );
              if (result != null) {
                Navigator.pop(context, result);
              }
            },
          ),
        ],
      ),

      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(51, 51, 51, 1),
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(entry.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(153, 161, 175, 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Content
              Text(
                entry.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color.fromRGBO(68, 68, 68, 1),
                ),
              ),
              const SizedBox(height: 24),
              // Tags
              if (entry.tags.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(51, 51, 51, 1),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: entry.tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(102, 102, 102, 1),
                        ),
                      ),
                      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
