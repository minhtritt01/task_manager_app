import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  late NotificationService _notificationService;

  TaskProvider() {
    _notificationService = NotificationService();
  }

  List<Task> get tasks => _filteredTasks.isNotEmpty ? _filteredTasks : _tasks;

  // Initialize the notification service
  void initNotificationService(BuildContext context) {
    _notificationService.init(context);
  }

  Future<void> loadTasks() async {
    try {
      final dbHelper = DatabaseHelper();
      final taskList = await dbHelper.getTasks();
      _tasks = taskList.map((task) => Task.fromMap(task)).toList();
      _filteredTasks = _tasks;
      notifyListeners();
    } catch (error) {
      rethrow; // Propagate the error to the FutureBuilder
    }
  }

  void filterTasks(bool showIncompleteOnly) {
    if (showIncompleteOnly) {
      _filteredTasks = _tasks.where((task) => task.status == 0).toList();
    } else {
      _filteredTasks = _tasks;
    }
    notifyListeners();
  }

  Future<int> addTask(Task task) async {
    try {
      final dbHelper = DatabaseHelper();
      int id = await dbHelper.insertTask(task.toMap());
      await loadTasks();

      // Schedule a notification for the new task
      await _notificationService.scheduleNotification(
        id: id,
        title: 'Task Due: ${task.title}',
        body: 'Your task "${task.title}" is due today!',
        dueDate: DateTime.parse(task.dueDate),
      );

      return id;
    } catch (error) {
      return -1; // Return -1 to indicate failure
    }
  }

  Future<int> updateTask(Task task) async {
    try {
      final dbHelper = DatabaseHelper();

      await _notificationService.cancelScheduleNotification(id: task.id!);

      int id = await dbHelper.updateTask(task.toMap());

      await loadTasks();

      final dueDate = DateTime.parse(task.dueDate);
      if (dueDate.isAfter(DateTime.now()) && task.status == 0) {
        await _notificationService.scheduleNotification(
          id: task.id!,
          title: 'Task Due: ${task.title}',
          body: 'Your task "${task.title}" is due today!',
          dueDate: dueDate,
        );
      }
      return id;
    } catch (error) {
      return -1;
    }
  }

  Future<int> deleteTask(int id) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.deleteTask(id);
      await loadTasks();

      // Cancel the notification for the deleted task
      await _notificationService.cancelScheduleNotification(id: id);

      return id;
    } catch (error) {
      return -1;
    }
  }

  void searchTasks(String keyword) {
    if (keyword.isEmpty) {
      _filteredTasks = _tasks;
    } else {
      _filteredTasks =
          _tasks.where((task) {
            return task.title.toLowerCase().contains(keyword.toLowerCase()) ||
                task.description.toLowerCase().contains(keyword.toLowerCase());
          }).toList();
    }
    notifyListeners();
  }
}
