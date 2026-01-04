import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';
import './todo_list_services.dart';

class MyDayResetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ToDoListService _listService = ToDoListService();

  static const String resetTaskName = "myDayReset";

  /// Initialize the background task
  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Schedule daily reset at midnight
    _scheduleNextReset();
  }

  /// Schedule the next reset at midnight
  static void _scheduleNextReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final delay = nextMidnight.difference(now);

    Workmanager().registerOneOffTask(
      resetTaskName,
      resetTaskName,
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    print('Next My Day reset scheduled for: $nextMidnight');
  }

  /// Manually reset My Day (for testing or immediate reset)
  Future<void> resetMyDay() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No user logged in');
        return;
      }

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      print('Resetting My Day for user: $userId');

      // Get the "My Day" list
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

      // Get all tasks in My Day
      final myDayTasksSnapshot = await _firestore
          .collection('toDoTasks')
          .where('userId', isEqualTo: userId)
          .where('listId', isEqualTo: myDayListId)
          .get();

      print('Found ${myDayTasksSnapshot.docs.length} tasks in My Day');

      if (myDayTasksSnapshot.docs.isEmpty) {
        print('No tasks to reset in My Day');
        return;
      }

      // Collect task names to update all instances
      Set<String> taskNamesToUpdate = {};
      for (var doc in myDayTasksSnapshot.docs) {
        final taskName = doc.data()['taskName'];
        if (taskName != null) {
          taskNamesToUpdate.add(taskName);
        }
      }

      // Update isMyDay flag to false for all instances of these tasks
      for (var taskName in taskNamesToUpdate) {
        final allInstancesSnapshot = await _firestore
            .collection('toDoTasks')
            .where('userId', isEqualTo: userId)
            .where('taskName', isEqualTo: taskName)
            .get();

        final batch = _firestore.batch();
        for (var doc in allInstancesSnapshot.docs) {
          batch.update(doc.reference, {
            'isMyDay': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }

      // Delete all tasks from My Day list
      int incompleteTasksRemoved = 0;
      final deleteBatch = _firestore.batch();

      for (var doc in myDayTasksSnapshot.docs) {
        final completionStatus = doc.data()['completionStatus'] ?? 0;
        if (completionStatus == 0) {
          incompleteTasksRemoved++;
        }
        deleteBatch.delete(doc.reference);
      }

      await deleteBatch.commit();

      // Update task count for My Day list (reset to 0)
      await _firestore.collection('toDoLists').doc(myDayListId).update({
        'taskCount': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('My Day reset complete. Removed ${myDayTasksSnapshot.docs.length} tasks');
      print('Incomplete tasks removed: $incompleteTasksRemoved');

      // Schedule next reset
      _scheduleNextReset();
    } catch (e) {
      print('Error resetting My Day: $e');
      rethrow;
    }
  }

  /// Check if reset is needed (for app startup)
  Future<void> checkAndResetIfNeeded() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userId = "NshL9WP7s7PyGofRZgJNUlbai6v2";

      // Get the My Day list to check last update
      final myDaySnapshot = await _firestore
          .collection('toDoLists')
          .where('userId', isEqualTo: userId)
          .where('listName', isEqualTo: 'My Day')
          .limit(1)
          .get();

      if (myDaySnapshot.docs.isEmpty) return;

      final myDayData = myDaySnapshot.docs.first.data();
      final updatedAt = myDayData['updatedAt'] as Timestamp?;

      if (updatedAt != null) {
        final lastUpdate = updatedAt.toDate();
        final now = DateTime.now();

        // Check if last update was on a different day
        if (lastUpdate.year != now.year ||
            lastUpdate.month != now.month ||
            lastUpdate.day != now.day) {
          print('My Day needs reset - last update: $lastUpdate, now: $now');
          await resetMyDay();
        } else {
          print('My Day already reset today');
        }
      }
    } catch (e) {
      print('Error checking My Day reset: $e');
    }
  }
}

/// Background task callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Background task started: $task');

    try {
      if (task == MyDayResetService.resetTaskName) {
        final resetService = MyDayResetService();
        await resetService.resetMyDay();
        print('My Day reset completed successfully');
      }
    } catch (e) {
      print('Error in background task: $e');
      return Future.value(false);
    }

    return Future.value(true);
  });
}