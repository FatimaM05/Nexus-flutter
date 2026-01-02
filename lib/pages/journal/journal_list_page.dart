import 'package:flutter/material.dart';
import 'package:nexus/widgets/custom_search_bar.dart';
import 'package:nexus/widgets/journal_entry_card.dart';
import 'package:nexus/widgets/empty_journal_state.dart';
import 'package:nexus/pages/journal/journal_detail_page.dart';
import 'package:nexus/pages/journal/new_entry_page.dart';
import 'package:nexus/models/journal_entry.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  List<JournalEntry> _entries = [];
  List<JournalEntry> _filteredEntries = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    // TODO: Replace with Firestore data
    final mockEntries = [
      JournalEntry(
        id: '1',
        title: 'A Productive Day',
        content:
            'Today was incredibly productive. I managed to complete the project proposal ahead of schedule and had a great meeting with the team.',
        date: DateTime(2024, 12, 6),
        tags: [],
      ),
      JournalEntry(
        id: '2',
        title: 'Grateful Morning',
        content:
            'Woke up feeling grateful. Sometimes the simplest moments bring the most joy. Had coffee on the balcony and watched the sunrise.',
        date: DateTime(2024, 12, 5),
        tags: [],
      ),
      JournalEntry(
        id: '3',
        title: 'Learning Flutter',
        content:
            'Spent the day learning new Flutter animations. The possibilities are endless when it comes to creating beautiful UIs.',
        date: DateTime(2024, 12, 4),
        tags: [],
      ),
    ];

    setState(() {
      _entries = mockEntries;
      _filteredEntries = mockEntries;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEntries = _entries;
      } else {
        _filteredEntries = _entries.where((entry) {
          return entry.title.toLowerCase().contains(query.toLowerCase()) ||
              entry.content.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _addNewEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewEntryPage()),
    );

    if (result != null && result is JournalEntry) {
      setState(() {
        _entries.insert(0, result);
        _filteredEntries = _entries;
      });
    }
  }

  void _viewEntryDetail(JournalEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JournalDetailPage(entry: entry)),
    );
  }

  void _deleteEntry(JournalEntry entry) {
    setState(() {
      _entries.remove(entry);
      _filteredEntries = _entries.where((e) {
        if (_searchQuery.isEmpty) return true;
        return e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.content.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16.0),
              child: CustomSearchBar(
                onSearch: _onSearch,
                hint: 'Search entries...',
              ),
            ),

            // Entries count - CHANGED TO MATCH SCREENSHOT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredEntries.length} entries', // ← CHANGED: Simplified text
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromRGBO(153, 161, 175, 1),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _onSearch('');
                      },
                      child: const Text(
                        'Clear search',
                        style: TextStyle(
                          color: Color.fromRGBO(160, 156, 176, 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const Divider(
              height: 20,
              thickness: 1,
              color: Color.fromRGBO(229, 231, 235, 1),
            ),

            // Entries List or Empty State
            Expanded(
              child: _filteredEntries.isEmpty
                  ? EmptyJournalState(onCreateEntry: _addNewEntry)
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _filteredEntries[index];
                        return JournalEntryCard(
                          entry: entry,
                          onTap: () => _viewEntryDetail(entry),
                          onDelete: () => _deleteEntry(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(160, 156, 176, 1),
        foregroundColor: Colors.white,
        onPressed: _addNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
