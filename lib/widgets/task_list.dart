import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/models/task.dart';

import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';
import '../services/notification_service.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.tasks,

    required this.notificationService,
  });
  final List<Task> tasks;
  final NotificationService notificationService;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(
          task: task,
          onCheckboxChanged: (value) {
            task.status = value! ? 1 : 0;
            context.read<TaskProvider>().updateTask(task);
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => TaskDetailScreen(
                      task: task,
                      notificationService: notificationService,
                    ),
              ),
            );
          },
        );
      },
    );
  }
}
