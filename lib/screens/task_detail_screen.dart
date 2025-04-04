import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/datetime_format.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  const TaskDetailScreen({super.key, this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = DateTime.parse(widget.task!.dueDate);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_titleController.text.isEmpty) {
        _showSnackBar('Title cannot be empty');
        return;
      }

      if (_descriptionController.text.isEmpty) {
        _showSnackBar('Description cannot be empty');
        return;
      }

      if (_dueDate == null) {
        _showSnackBar('Please select a due date');
        return;
      }
      if (_dueDate!.isBefore(DateTime.now())) {
        _showSnackBar('Due date must be in the future');
        return;
      }

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final newTask = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        status: widget.task?.status ?? 0,
        dueDate: _dueDate!.toIso8601String(),
        createdAt: widget.task?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt:
            widget.task == null
                ? ''
                : DateTime.now()
                    .toIso8601String(), // only set updatedAt when the task is updated
      );

      if (widget.task == null) {
        await taskProvider.addTask(newTask);
        _showSnackBar('Task added successfully');
      } else {
        await taskProvider.updateTask(newTask);
        _showSnackBar('Task updated successfully');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _deleteTask() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Task'),
            content: Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await taskProvider.deleteTask(widget.task!.id!);
      _showSnackBar('Task deleted successfully');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (widget.task != null)
            IconButton(icon: Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text(
                  _dueDate == null
                      ? 'Select Due Date & Time'
                      : 'Due Date: ${DateFormat(datetime).format(_dueDate!)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null && context.mounted) {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        _dueDate ?? DateTime.now(),
                      ),
                    );

                    if (selectedTime != null) {
                      setState(() {
                        _dueDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
