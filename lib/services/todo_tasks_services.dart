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

  /// Deletes a task from all lists it appears in
  Future<void> deleteTask(String taskId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      // Get the task to find its name and list
      final taskDoc = await _firestore
          .collection('toDoTasks')
          .doc(taskId)
          .get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data()!;
      final taskName = taskData['taskName'];

      // Find ALL instances of this task across all lists
      final allInstancesSnapshot = await _firestore
          .collection('toDoTasks')
          .where('userId', isEqualTo: userId)
          .where('taskName', isEqualTo: taskName)
          .get();

      // Group tasks by listId to update task counts
      Map<String, int> listCountUpdates = {};

      for (var doc in allInstancesSnapshot.docs) {
        final instanceData = doc.data();
        final instanceListId = instanceData['listId'];
        final instanceCompletionStatus = instanceData['completionStatus'] ?? 0;

        // Only count incomplete tasks for decrementing
        if (instanceCompletionStatus == 0) {
          listCountUpdates[instanceListId] =
              (listCountUpdates[instanceListId] ?? 0) + 1;
        }
      }

      // Delete all instances in a batch
      final batch = _firestore.batch();
      for (var doc in allInstancesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update task counts for affected lists
      for (var entry in listCountUpdates.entries) {
        final listId = entry.key;
        final countToDecrement = entry.value;

        await _listService.decrementTaskCount(listId);
        print('Decremented task count by $countToDecrement for list: $listId');
      }
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  /// Updates a task's important status
  Future<void> updateTaskImportantStatus(
    String taskId,
    bool isImportant,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      // Get the task details
      final taskDoc = await _firestore
          .collection('toDoTasks')
          .doc(taskId)
          .get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data()!;
      final taskName = taskData['taskName'];
      final completionStatus = taskData['completionStatus'] ?? 0;
      final notes = taskData['notes'] ?? '';
      final isMyDay = taskData['isMyDay'] ?? false;

      // Update all instances of this task
      final allInstancesSnapshot = await _firestore
          .collection('toDoTasks')
          .where('userId', isEqualTo: userId)
          .where('taskName', isEqualTo: taskName)
          .get();

      // Update all instances
      final batch = _firestore.batch();
      for (var doc in allInstancesSnapshot.docs) {
        batch.update(doc.reference, {
          'isImportant': isImportant,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      // Get "Important Tasks" list
      final importantTasksSnapshot = await _firestore
          .collection('toDoLists')
          .where('userId', isEqualTo: userId)
          .where('listName', isEqualTo: 'Important Tasks')
          .limit(1)
          .get();

      if (importantTasksSnapshot.docs.isEmpty) {
        print('Important Tasks list not found');
        return;
      }

      final importantTasksListId = importantTasksSnapshot.docs.first.id;

      if (isImportant) {
        // Check if task already exists in Important Tasks
        final existingTaskSnapshot = await _firestore
            .collection('toDoTasks')
            .where('userId', isEqualTo: userId)
            .where('listId', isEqualTo: importantTasksListId)
            .where('taskName', isEqualTo: taskName)
            .limit(1)
            .get();

        if (existingTaskSnapshot.docs.isEmpty) {
          // Add to Important Tasks list
          await _firestore.collection('toDoTasks').add({
            'userId': userId,
            'listId': importantTasksListId,
            'taskName': taskName,
            'completionStatus': completionStatus,
            'notes': notes,
            'isImportant': true,
            'isMyDay': isMyDay,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Increment count only if task is incomplete
          if (completionStatus == 0) {
            await _listService.incrementTaskCount(importantTasksListId);
          }
        }
      } else {
        // Remove from Important Tasks list
        final tasksToRemove = await _firestore
            .collection('toDoTasks')
            .where('userId', isEqualTo: userId)
            .where('listId', isEqualTo: importantTasksListId)
            .where('taskName', isEqualTo: taskName)
            .get();

        final deleteBatch = _firestore.batch();
        int incompleteTasksRemoved = 0;

        for (var doc in tasksToRemove.docs) {
          final docCompletionStatus = doc.data()['completionStatus'] ?? 0;
          if (docCompletionStatus == 0) {
            incompleteTasksRemoved++;
          }
          deleteBatch.delete(doc.reference);
        }

        await deleteBatch.commit();

        // Decrement count for incomplete tasks removed
        if (incompleteTasksRemoved > 0) {
          for (int i = 0; i < incompleteTasksRemoved; i++) {
            await _listService.decrementTaskCount(importantTasksListId);
          }
        }
      }
    } catch (e) {
      print('Error updating task important status: $e');
      rethrow;
    }
  }

  /// Updates a task's My Day status
  Future<void> updateTaskMyDayStatus(String taskId, bool isMyDay) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      // Get the task details
      final taskDoc = await _firestore
          .collection('toDoTasks')
          .doc(taskId)
          .get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data()!;
      final taskName = taskData['taskName'];
      final completionStatus = taskData['completionStatus'] ?? 0;
      final notes = taskData['notes'];
      final isImportant = taskData['isImportant'] ?? false;

      // Update all instances of this task
      final allInstancesSnapshot = await _firestore
          .collection('toDoTasks')
          .where('userId', isEqualTo: userId)
          .where('taskName', isEqualTo: taskName)
          .get();

      // Update all instances
      final batch = _firestore.batch();
      for (var doc in allInstancesSnapshot.docs) {
        batch.update(doc.reference, {
          'isMyDay': isMyDay,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      // Get "My Day" list
      final myDaySnapshot = await _firestore
          .collection('toDoLists')
          .where('userId', isEqualTo: userId)
          .where('listName', isEqualTo: 'My Day')
          .limit(1)
          .get();

      if (myDaySnapshot.docs.isEmpty) {
        print('My Day list not found');
        return;
      }

      final myDayListId = myDaySnapshot.docs.first.id;

      if (isMyDay) {
        // Check if task already exists in My Day
        final existingTaskSnapshot = await _firestore
            .collection('toDoTasks')
            .where('userId', isEqualTo: userId)
            .where('listId', isEqualTo: myDayListId)
            .where('taskName', isEqualTo: taskName)
            .limit(1)
            .get();

        if (existingTaskSnapshot.docs.isEmpty) {
          // Add to My Day list
          await _firestore.collection('toDoTasks').add({
            'userId': userId,
            'listId': myDayListId,
            'taskName': taskName,
            'completionStatus': completionStatus,
            'notes': notes,
            'isImportant': isImportant,
            'isMyDay': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Increment count only if task is incomplete
          if (completionStatus == 0) {
            await _listService.incrementTaskCount(myDayListId);
          }
        }
      } else {
        // Remove from My Day list
        final tasksToRemove = await _firestore
            .collection('toDoTasks')
            .where('userId', isEqualTo: userId)
            .where('listId', isEqualTo: myDayListId)
            .where('taskName', isEqualTo: taskName)
            .get();

        final deleteBatch = _firestore.batch();
        int incompleteTasksRemoved = 0;

        for (var doc in tasksToRemove.docs) {
          final docCompletionStatus = doc.data()['completionStatus'] ?? 0;
          if (docCompletionStatus == 0) {
            incompleteTasksRemoved++;
          }
          deleteBatch.delete(doc.reference);
        }

        await deleteBatch.commit();

        // Decrement count for incomplete tasks removed
        if (incompleteTasksRemoved > 0) {
          for (int i = 0; i < incompleteTasksRemoved; i++) {
            await _listService.decrementTaskCount(myDayListId);
          }
        }
      }
    } catch (e) {
      print('Error updating task My Day status: $e');
      rethrow;
    }
  }

  /// Moves a task to a different list
  Future<void> moveTaskToList(String taskId, String targetListId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      // Get the task details
      final taskDoc = await _firestore
          .collection('toDoTasks')
          .doc(taskId)
          .get();
      if (!taskDoc.exists) {
        throw Exception('Task not found');
      }

      final taskData = taskDoc.data()!;
      final currentListId = taskData['listId'];
      final completionStatus = taskData['completionStatus'] ?? 0;

      // Don't do anything if already in the target list
      if (currentListId == targetListId) {
        return;
      }

      // Update the task's listId
      await _firestore.collection('toDoTasks').doc(taskId).update({
        'listId': targetListId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update task counts
      // Only update counts for incomplete tasks
      if (completionStatus == 0) {
        // Decrement count from old list
        await _listService.decrementTaskCount(currentListId);

        // Increment count for new list
        await _listService.incrementTaskCount(targetListId);
      }

    } catch (e) {
      print('Error moving task: $e');
      rethrow;
    }
  }

  /// Checks if a list exists for the current user
  Future<String?> getListIdByName(String listName) async {
    try {
      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      final querySnapshot = await _firestore
          .collection('toDoLists')
          .where('userId', isEqualTo: userId)
          .where('listName', isEqualTo: listName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first.id;
    } catch (e) {
      print('Error checking list existence: $e');
      rethrow;
    }
  }

}
