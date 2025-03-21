import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/providers/theme_provider.dart';
import 'package:task_manager_app/widgets/task_list.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import 'search_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  bool _showIncompleteOnly = false;
  late NotificationService _notificationService;
  @override
  void initState() {
    _notificationService = NotificationService();
    if (context.mounted) {
      _notificationService.init(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: const Text('Unfinished'),
              ),
              Switch(
                value: _showIncompleteOnly,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _showIncompleteOnly = value;
                  });
                  Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).filterTasks(value);
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TaskDetailScreen(
                        notificationService: _notificationService,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SearchScreen(
                        notificationService: _notificationService,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return TaskList(
            tasks: taskProvider.tasks,
            notificationService: _notificationService,
          );
        },
      ),
      floatingActionButton: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return FloatingActionButton(
            child: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.toggleTheme(
                themeProvider.themeMode == ThemeMode.light,
              );
            },
          );
        },
      ),
    );
  }
}
