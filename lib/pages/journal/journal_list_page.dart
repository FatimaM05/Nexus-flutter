import 'package:flutter/material.dart';
import 'package:nexus/widgets/custom_search_bar.dart';
import 'package:nexus/widgets/journal_entry_card.dart';
import 'package:nexus/widgets/empty_journal_state.dart';
import 'package:nexus/pages/journal/journal_detail_page.dart';
import 'package:nexus/pages/journal/new_entry_page.dart';
import 'package:nexus/models/journal_entry.dart';
import 'package:nexus/pages/journal/firebase_service.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // No need to load entries here as we'll use StreamBuilder
  }

  void _onSearch(String query, List<JournalEntry> allEntries) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _addNewEntry() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewEntryPage()),
    );

    if (result != null && result is JournalEntry) {
      // No need to manually add to list - StreamBuilder will update automatically
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry added successfully')));
    }
  }

  void _viewEntryDetail(JournalEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => JournalDetailPage(entry: entry)),
    );

    if (result != null && result is JournalEntry) {
      // Entry was updated - StreamBuilder will handle the update automatically
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry updated successfully')),
      );
    }
  }

  void _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firebaseService.deleteJournalEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
      }
    }
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
        child: StreamBuilder<List<JournalEntry>>(
          stream: _firebaseService.getJournalEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading entries: ${snapshot.error}'),
              );
            }

            final allEntries = snapshot.data ?? [];
            final filteredEntries = _searchQuery.isEmpty
                ? allEntries
                : allEntries.where((entry) {
                    return entry.title.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        entry.content.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                  }).toList();

            return Column(
              children: [
                // Search Bar
                Container(
                  margin: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
                    onSearch: (query) => _onSearch(query, allEntries),
                    hint: 'Search entries...',
                  ),
                ),

                // Entries count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredEntries.length} entries',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(153, 161, 175, 1),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () => _onSearch('', allEntries),
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
                  child: filteredEntries.isEmpty
                      ? EmptyJournalState(onCreateEntry: _addNewEntry)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = filteredEntries[index];
                            return JournalEntryCard(
                              entry: entry,
                              onTap: () => _viewEntryDetail(entry),
                              onDelete: () => _deleteEntry(entry),
                            );
                          },
                        ),
                ),
              ],
            );
          },
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
