import 'package:flutter/material.dart';
import '../constants/datetime_format.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(bool?) onCheckboxChanged;
  final Function() onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.onCheckboxChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat(datetime);
    final dueDate =
        'Due date: ${dateFormat.format(DateTime.tryParse(task.dueDate) ?? DateTime.now())}';

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration:
                task.status == 1
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              dueDate,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                decoration:
                    task.status == 1
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
              ),
            ),
            SizedBox(height: 4),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                decoration:
                    task.status == 1
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
              ),
            ),
          ],
        ),
        trailing: Checkbox(
          value: task.status == 1,
          onChanged: onCheckboxChanged,
          activeColor: Colors.green,
        ),
        onTap: onTap,
      ),
    );
  }
}
