import 'package:flutter/material.dart';
import '../models/task.dart';

/// Task Item Widget
/// 
/// Displays a single task with:
/// - Checkbox to toggle completion
/// - Task title (with strikethrough if completed)
/// - Due date (if set)
/// - Edit and delete actions
class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String) onEdit;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      // Swipe to delete
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: colorScheme.onError,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildCheckbox(colorScheme),
          title: _buildTitle(theme),
          subtitle: _buildSubtitle(theme),
          trailing: _buildActions(context),
        ),
      ),
    );
  }

  /// Build the completion checkbox
  Widget _buildCheckbox(ColorScheme colorScheme) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: task.isCompleted 
                ? colorScheme.primary 
                : colorScheme.outline,
            width: 2,
          ),
          color: task.isCompleted 
              ? colorScheme.primary 
              : Colors.transparent,
        ),
        child: task.isCompleted
            ? Icon(
                Icons.check,
                size: 16,
                color: colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }

  /// Build the task title
  Widget _buildTitle(ThemeData theme) {
    return Text(
      task.title,
      style: theme.textTheme.bodyLarge?.copyWith(
        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        color: task.isCompleted 
            ? theme.colorScheme.onSurface.withOpacity(0.6)
            : theme.colorScheme.onSurface,
        fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build the subtitle (due date)
  Widget _buildSubtitle(ThemeData theme) {
    if (task.dueDate == null) return const SizedBox.shrink();

    final isOverdue = task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 12,
            color: isOverdue 
                ? theme.colorScheme.error 
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDate(task.dueDate!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isOverdue 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          if (isOverdue)
            Text(
              ' (逾期)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showEditDialog(context),
          tooltip: '编辑',
          color: Theme.of(context).colorScheme.primary,
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteConfirmation(context),
          tooltip: '删除',
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }

  /// Show edit dialog
  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: task.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑任务'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '任务内容',
            hintText: '输入新的任务内容',
          ),
          maxLines: 3,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              onEdit(controller.text);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个任务吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return '今天';
    } else if (dateToCheck == today.add(const Duration(days: 1))) {
      return '明天';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}
