import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/empty_state.dart';

/// Home Screen
/// 
/// The main screen of the app displaying:
/// - App bar with title and clear completed action
/// - Filter chips for task filtering
/// - List of tasks
/// - Floating action button to add new tasks
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(colorScheme, theme),
          // Filter Chips
          _buildFilterChips(),
          // Task List
          _buildTaskList(),
        ],
      ),
      floatingActionButton: _buildFAB(colorScheme),
    );
  }

  /// Build the app bar
  Widget _buildAppBar(ColorScheme colorScheme, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              color: colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              '待办事项',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      actions: [
        // Clear completed button
        Consumer<TaskProvider>(
          builder: (context, provider, child) {
            if (provider.completedTaskCount == 0) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: '清除已完成',
              onPressed: () => _showClearCompletedDialog(context, provider),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          return FilterChipBar(
            currentFilter: provider.currentFilter,
            onFilterChanged: provider.setFilter,
            allCount: provider.totalTaskCount,
            activeCount: provider.activeTaskCount,
            completedCount: provider.completedTaskCount,
          );
        },
      ),
    );
  }

  /// Build the task list
  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        // Show loading indicator
        if (provider.isLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show error if any
        if (provider.error != null) {
          return SliverFillRemaining(
            child: _buildErrorState(context, provider),
          );
        }

        final tasks = provider.filteredTasks;

        // Show empty state
        if (tasks.isEmpty) {
          return SliverFillRemaining(
            child: EmptyState(
              isFiltered: provider.currentFilter != TaskFilter.all,
            ),
          );
        }

        // Show task list
        return SliverPadding(
          padding: const EdgeInsets.only(bottom: 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = tasks[index];
                return TaskItem(
                  task: task,
                  onToggle: () => provider.toggleTask(task.id),
                  onDelete: () => provider.deleteTask(task.id),
                  onEdit: (newTitle) => provider.editTask(task.id, newTitle),
                );
              },
              childCount: tasks.length,
            ),
          ),
        );
      },
    );
  }

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, TaskProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '出错了',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                provider.clearError();
                provider.loadTasks();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build floating action button
  Widget _buildFAB(ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddTaskDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('新任务'),
      elevation: 4,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    );
  }

  /// Show add task dialog
  Future<void> _showAddTaskDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );

    if (result != null && result['title'] != null) {
      final provider = context.read<TaskProvider>();
      await provider.addTask(
        result['title'] as String,
        dueDate: result['dueDate'] as DateTime?,
      );
    }
  }

  /// Show clear completed confirmation dialog
  void _showClearCompletedDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除已完成任务'),
        content: Text(
          '确定要清除 ${provider.completedTaskCount} 个已完成的任务吗？此操作无法撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              provider.clearCompleted();
              Navigator.pop(context);
              // Show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已清除所有完成的任务'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
}
