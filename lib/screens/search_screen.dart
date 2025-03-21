import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/task_list.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.notificationService});
  final NotificationService notificationService;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final keyword = _searchController.text;
    Provider.of<TaskProvider>(context, listen: false).searchTasks(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search tasks...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, searchProvider, child) {
          return TaskList(
            tasks: searchProvider.tasks,
            notificationService: widget.notificationService,
          );
        },
      ),
    );
  }
}
