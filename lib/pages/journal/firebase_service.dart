// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/models/journal_entry.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference - using a general collection without user authentication
  CollectionReference get _journalEntriesCollection {
    return _firestore.collection('journal_entries');
  }

  // Add a new journal entry. Returns the document id of the saved entry.
  Future<String> addJournalEntry(JournalEntry entry) async {
    try {
      if (entry.id.isEmpty) {
        final docRef = _journalEntriesCollection.doc();
        final newEntry = entry.copyWith(id: docRef.id);
        await docRef.set(newEntry.toMap());
        return docRef.id;
      } else {
        await _journalEntriesCollection.doc(entry.id).set(entry.toMap());
        return entry.id;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing journal entry
  Future<void> updateJournalEntry(JournalEntry entry) async {
    try {
      await _journalEntriesCollection.doc(entry.id).update(entry.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete a journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _journalEntriesCollection.doc(entryId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get all journal entries
  Stream<List<JournalEntry>> getJournalEntries() {
    try {
      return _journalEntriesCollection
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return JournalEntry.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();
          });
    } catch (e) {
      return const Stream.empty();
    }
  }

  // Search journal entries
  Future<List<JournalEntry>> searchJournalEntries(String query) async {
    try {
      final snapshot = await _journalEntriesCollection.get();
      final entries = snapshot.docs.map((doc) {
        return JournalEntry.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      return entries.where((entry) {
        return entry.title.toLowerCase().contains(query.toLowerCase()) ||
            entry.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
