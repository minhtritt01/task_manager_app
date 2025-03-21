import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  List<Task> get tasks => _filteredTasks.isNotEmpty ? _filteredTasks : _tasks;

  Future<void> loadTasks() async {
    final dbHelper = DatabaseHelper();
    final taskList = await dbHelper.getTasks();
    _tasks = taskList.map((task) => Task.fromMap(task)).toList();
    _filteredTasks = _tasks;
    notifyListeners();
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
    final dbHelper = DatabaseHelper();
    int id = await dbHelper.insertTask(task.toMap());
    await loadTasks();
    return id;
  }

  Future<int> updateTask(Task task) async {
    final dbHelper = DatabaseHelper();
    int id = await dbHelper.updateTask(task.toMap());
    await loadTasks();
    return id;
  }

  Future<int> deleteTask(int id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteTask(id);
    await loadTasks();
    return id;
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
