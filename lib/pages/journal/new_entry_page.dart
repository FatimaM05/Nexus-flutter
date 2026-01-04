import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexus/models/journal_entry.dart';

class NewEntryPage extends StatefulWidget {
  final JournalEntry? existingEntry;

  const NewEntryPage({super.key, this.existingEntry});

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _titleController.text = widget.existingEntry!.title;
      _contentController.text = widget.existingEntry!.content;
      _selectedDate = widget.existingEntry!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and content')),
      );
      return;
    }

    final entry = JournalEntry(
      id:
          widget.existingEntry?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      date: _selectedDate,
      tags: [],
    );

    Navigator.pop(context, entry);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry == null ? 'New Entry' : 'Edit Entry'),
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
          TextButton(
            onPressed: _saveEntry,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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

              Text(
                DateFormat('MM/dd/yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Entry Title',
                  hintStyle: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              const SizedBox(height: 16),

              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your thoughts...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
                maxLines: 10,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}