import 'package:flutter/material.dart';

/// Add Task Dialog
///
/// A dialog for adding new tasks with optional due date selection
class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _controller = TextEditingController();
  DateTime? _selectedDate;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.add_task,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('添加新任务'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task input field
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: '任务内容',
              hintText: '输入你要完成的任务...',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          // Due date selector
          _buildDateSelector(colorScheme),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('添加'),
        ),
      ],
    );
  }

  /// Build the due date selector
  Widget _buildDateSelector(ColorScheme colorScheme) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedDate != null
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: _selectedDate != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedDate != null ? _formatDate(_selectedDate!) : '设置截止日期',
              style: TextStyle(
                color: _selectedDate != null
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight:
                    _selectedDate != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Open date picker
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)), // 5 years from now
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Submit the form
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    Navigator.pop(context, {
      'title': text,
      'dueDate': _selectedDate,
    });
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
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}
