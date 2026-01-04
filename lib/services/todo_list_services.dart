import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/models/todo_list_model.dart';
import '../models/todo_task_model.dart';

class ToDoListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Listens to real-time updates of to-do lists for the current user
  Stream<List<ToDoListModel>> listenToLists() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    //final userId = currentUser.uid;
    final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

    print('Setting up listener for userId: $userId');

    return _firestore
        .collection('toDoLists')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('Snapshot received: ${snapshot.docs.length} lists');

          List<ToDoListModel> allLists = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();
            print('List: ${data['listName']}, taskCount: ${data['taskCount']}');

            allLists.add(
              ToDoListModel(
                id: doc.id,
                name: data['listName'] ?? '',
                numberOfTasks: data['taskCount'] ?? 0,
                isDefault: data['isDefault'] ?? false,
              ),
            );
          }

          // Sort and return
          return _sortLists(allLists);
        });
  }

  // /// Fetches all to-do lists for the current user (one-time fetch)
  // Future<List<ToDoListModel>> fetchAllLists() async {
  //   try {
  //     final currentUser = _auth.currentUser;
  //     if (currentUser == null) {
  //       throw Exception('No user logged in');
  //     }

  //     //final userId = currentUser.uid;
  //     final userId =
  //         "NshL9WP7s7PyGofRZgJNUlbai6v2"; // temporary hardcoded userId

  //     print('Fetching lists for userId: $userId');

  //     final querySnapshot = await _firestore
  //         .collection('toDoLists')
  //         .where('userId', isEqualTo: userId)
  //         .get();

  //     print('Found ${querySnapshot.docs.length} lists');

  //     List<ToDoListModel> allLists = [];

  //     for (var doc in querySnapshot.docs) {
  //       final data = doc.data();
  //       print('List found: ${data['listName']}');

  //       allLists.add(
  //         ToDoListModel(
  //           id: doc.id,
  //           name: data['listName'] ?? '',
  //           numberOfTasks: data['taskCount'] ?? 0,
  //           isDefault: data['isDefault'] ?? false,
  //         ),
  //       );
  //     }

  //     final sortedLists = _sortLists(allLists);
  //     print('Returning ${sortedLists.length} sorted lists');

  //     return sortedLists;
  //   } catch (e) {
  //     print('Error fetching lists: $e');
  //     rethrow;
  //   }
  // }

  /// Sorts lists to place default lists at the top in specific order
  List<ToDoListModel> _sortLists(List<ToDoListModel> lists) {
    final defaultOrder = ['My Day', 'Important Tasks', 'All Tasks'];

    List<ToDoListModel> defaultLists = [];
    List<ToDoListModel> customLists = [];

    // Separate default and custom lists
    for (var list in lists) {
      if (defaultOrder.contains(list.name)) {
        defaultLists.add(list);
      } else {
        customLists.add(list);
      }
    }

    // Sort default lists according to the specific order
    defaultLists.sort((a, b) {
      int indexA = defaultOrder.indexOf(a.name);
      int indexB = defaultOrder.indexOf(b.name);
      return indexA.compareTo(indexB);
    });

    // Combine: default lists first, then custom lists
    return [...defaultLists, ...customLists];
  }

  /// Creates default lists for a new user
  Future<void> createDefaultLists(String userId) async {
    try {
      final defaultLists = [
        {
          'userId': userId,
          'listName': 'My Day',
          'isDefault': true,
          'taskCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': userId,
          'listName': 'Important Tasks',
          'isDefault': true,
          'taskCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': userId,
          'listName': 'All Tasks',
          'isDefault': true,
          'taskCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var listData in defaultLists) {
        await _firestore.collection('toDoLists').add(listData);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Increment task count when a task is added
  Future<void> incrementTaskCount(String listId) async {
    await _firestore.collection('toDoLists').doc(listId).update({
      'taskCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Decrement task count when a task is removed
  Future<void> decrementTaskCount(String listId) async {
    await _firestore.collection('toDoLists').doc(listId).update({
      'taskCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  //method to create a new list through the todo_hub.dart fab
  Future<ToDoListModel> createNewList(String listName) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      //final userId = currentUser.uid;
      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      final docRef = await _firestore.collection('toDoLists').add({
        'userId': userId,
        'listName': listName,
        'isDefault': false,
        'taskCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }); //will return the id of the todo list document that's created

      ToDoListModel newList = ToDoListModel(
        id: docRef.id,
        name: listName,
        numberOfTasks: 0,
        isDefault: false,
      );

      return newList; // Return the new ToDoListModel instance
    } catch (e) {
      print('Error creating new list: $e');
      rethrow;
    }
  }

  // getting all tasks for a list
  Stream<List<ToDoTaskModel>> fetchAllTasks(String listId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    //final userId = currentUser.uid;
    final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

    return _firestore
        .collection('toDoTasks')
        .where('userId', isEqualTo: userId)
        .where('listId', isEqualTo: listId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            print('WARNING: No tasks found for listId: $listId');
          }
          List<ToDoTaskModel> allTasks = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();

            allTasks.add(ToDoTaskModel.fromFirestore(data, doc.id));
          }

          return allTasks;
        });
  }

  //updating list name
  Future<void> updateListName(String listId, String newListName) async {
    try {
      await _firestore.collection('toDoLists').doc(listId).update({
        'listName': newListName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating list name: $e');
      rethrow;
    }
  }

  /// Deletes a list and all its tasks
  Future<void> deleteList(String listId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      // Get all tasks belonging to this list
      final tasksSnapshot = await _firestore
          .collection('toDoTasks')
          .where('userId', isEqualTo: userId)
          .where('listId', isEqualTo: listId)
          .get();

      // Collect all task names to find duplicates in other lists
      Set<String> taskNamesToDelete = {};
      for (var taskDoc in tasksSnapshot.docs) {
        final taskName = taskDoc.data()['taskName'];
        if (taskName != null) {
          taskNamesToDelete.add(taskName);
        }
      }

      // Find ALL instances of these tasks across all lists
      List<DocumentSnapshot> allTaskInstances = [];

      for (var taskName in taskNamesToDelete) {
        final duplicatesSnapshot = await _firestore
            .collection('toDoTasks')
            .where('userId', isEqualTo: userId)
            .where('taskName', isEqualTo: taskName)
            .get();

        allTaskInstances.addAll(duplicatesSnapshot.docs);
      }

      // Group tasks by listId to update task counts
      Map<String, int> listCountUpdates = {};
      for (var taskDoc in allTaskInstances) {
        final data = taskDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          final taskListId = data['listId'];
          final completionStatus = data['completionStatus'] ?? 0;

          // Only count incomplete tasks for decrementing
          if (completionStatus == 0) {
            listCountUpdates[taskListId] =
                (listCountUpdates[taskListId] ?? 0) + 1;
          }
        }
      }

      // Delete all task instances in a batch
      final batch = _firestore.batch();
      for (var taskDoc in allTaskInstances) {
        batch.delete(taskDoc.reference);
      }
      await batch.commit();

      // Update task counts for affected lists
      for (var entry in listCountUpdates.entries) {
        final affectedListId = entry.key;
        final countToDecrement = entry.value;

        await _firestore.collection('toDoLists').doc(affectedListId).update({
          'taskCount': FieldValue.increment(-countToDecrement),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Finally, delete the list itself
      await _firestore.collection('toDoLists').doc(listId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Searches for tasks across all lists based on query
  Stream<List<ToDoTaskModel>> searchTasks(String query) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

    if (query.trim().isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('toDoTasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          List<ToDoTaskModel> matchingTasks = [];
          final searchQuery = query.toLowerCase();

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final taskName = (data['taskName'] ?? '').toString().toLowerCase();

            // Check if task name contains the search query
            if (taskName.contains(searchQuery)) {
              matchingTasks.add(ToDoTaskModel.fromFirestore(data, doc.id));
            }
          }

          return matchingTasks;
        });
  }

  // ...existing code...
}
