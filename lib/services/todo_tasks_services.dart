import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_task_model.dart';
import './todo_list_services.dart';

class ToDoTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ToDoListService _listService = ToDoListService();

  /// Creates a new task in a specific list
  Future<ToDoTaskModel> createTask({
    required String listId,
    required String taskName,
    String? notes,
    bool isImportant = false,
    bool isMyDay = false,
    bool repeat = false,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      print('Creating task: $taskName for listId: $listId');

      // Create the task
      final docRef = await _firestore.collection('toDoTasks').add({
        'userId': userId,
        'listId': listId,
        'taskName': taskName,
        'completionStatus': 0,
        'notes': notes,
        'isImportant': isImportant,
        'isMyDay': isMyDay,
        'repeat': repeat,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Increment task count for the specific list
      await _listService.incrementTaskCount(listId);

      // Also add to "All Tasks" list if not already creating in "All Tasks"
      final allTasksSnapshot = await _firestore
          .collection('toDoLists')
          .where('userId', isEqualTo: userId)
          .where('listName', isEqualTo: 'All Tasks')
          .limit(1)
          .get();

      if (allTasksSnapshot.docs.isNotEmpty) {
        final allTasksListId = allTasksSnapshot.docs.first.id;

        // Only create duplicate in "All Tasks" if we're not already creating there
        if (listId != allTasksListId) {
          // Create a duplicate task in "All Tasks" list
          await _firestore.collection('toDoTasks').add({
            'userId': userId,
            'listId': allTasksListId,
            'taskName': taskName,
            'completionStatus': 0,
            'notes': notes,
            'isImportant': isImportant,
            'isMyDay': isMyDay,
            'repeat': repeat,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Increment task count for "All Tasks" list
          await _listService.incrementTaskCount(allTasksListId);
          print('Task also added to All Tasks list');
        }
      }

      print('Task created successfully with ID: ${docRef.id}');

      return ToDoTaskModel(
        id: docRef.id,
        listId: listId,
        name: taskName,
        completionStatus: 0,
        notes: notes,
        isImportant: isImportant,
        isMyDay: isMyDay,
        repeat: repeat,
      );
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  /// Updates an existing task's name
  Future<void> updateTaskName(String taskId, String newTaskName) async {
    try {
      print('Updating task $taskId with new name: $newTaskName');

      await _firestore.collection('toDoTasks').doc(taskId).update({
        'taskName': newTaskName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Task name updated successfully');
    } catch (e) {
      print('Error updating task name: $e');
      rethrow;
    }
  }

  /// Updates an existing task's notes
  Future<void> updateTaskNotes(String taskId, String? notes) async {
    try {
      print('Updating task $taskId with new notes');

      await _firestore.collection('toDoTasks').doc(taskId).update({
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Task notes updated successfully');
    } catch (e) {
      print('Error updating task notes: $e');
      rethrow;
    }
  }

  /// Updates task completion status
  Future<void> updateTaskStatus(String taskId, int completionStatus) async {
    try {
      print('Updating task $taskId completion status to: $completionStatus');

      // Get the task to find which lists it belongs to
      final taskDoc = await _firestore
          .collection('toDoTasks')
          .doc(taskId)
          .get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data()!;
      final oldStatus = taskData['completionStatus'] ?? 0;
      final listId = taskData['listId'];
      // Update task status in the database
      await _firestore.collection('toDoTasks').doc(taskId).update({
        'completionStatus': completionStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'completedAt': completionStatus == 1
            ? FieldValue.serverTimestamp()
            : null,
      });

      // Update task count based on status change
      if (oldStatus == 0 && completionStatus == 1) {
        // Task was incomplete, now complete -> decrement count
        await _listService.decrementTaskCount(listId);
        print('Decremented task count for list: $listId');
      } else if (oldStatus == 1 && completionStatus == 0) {
        // Task was complete, now incomplete -> increment count
        await _listService.incrementTaskCount(listId);
        print('Incremented task count for list: $listId');
      }

      // Now find and update ALL instances of this task in other lists
      // (since tasks can exist in multiple lists like "All Tasks", "My Day", etc.)
      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";
      final taskName = taskData['taskName'];

      final allInstancesSnapshot = await _firestore
          .collection('toDoTasks')
          .where('userId', isEqualTo: userId)
          .where('taskName', isEqualTo: taskName)
          .get();

      // Update all instances and their list counts
      for (var doc in allInstancesSnapshot.docs) {
        if (doc.id != taskId) {
          // Skip the original task we already updated
          final instanceData = doc.data();
          final instanceListId = instanceData['listId'];
          final instanceOldStatus = instanceData['completionStatus'] ?? 0;

          // Update the task instance
          await _firestore.collection('toDoTasks').doc(doc.id).update({
            'completionStatus': completionStatus,
            'updatedAt': FieldValue.serverTimestamp(),
            'completedAt': completionStatus == 1
                ? FieldValue.serverTimestamp()
                : null,
          });

          // Update task count for this list
          if (instanceOldStatus == 0 && completionStatus == 1) {
            await _listService.decrementTaskCount(instanceListId);
            print('Decremented task count for list: $instanceListId');
          } else if (instanceOldStatus == 1 && completionStatus == 0) {
            await _listService.incrementTaskCount(instanceListId);
            print('Incremented task count for list: $instanceListId');
          }
        }
      }

      print('Task status updated successfully');
    } catch (e) {
      print('Error updating task status: $e');
      rethrow;
    }
  }
}
