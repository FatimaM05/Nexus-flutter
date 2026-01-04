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
        title: Text(entry.title, style: TextStyle(fontWeight: FontWeight.w600)),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(
            color: const Color.fromRGBO(200, 200, 200, 1),
            width: 1.0,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
