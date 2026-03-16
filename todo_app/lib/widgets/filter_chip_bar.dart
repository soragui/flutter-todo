import 'package:flutter/material.dart';
import '../models/task.dart';

/// Filter Chip Bar
/// 
/// Displays filter chips for switching between:
/// - All tasks
/// - Active (incomplete) tasks  
/// - Completed tasks
class FilterChipBar extends StatelessWidget {
  final TaskFilter currentFilter;
  final Function(TaskFilter) onFilterChanged;
  final int allCount;
  final int activeCount;
  final int completedCount;

  const FilterChipBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.allCount,
    required this.activeCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            filter: TaskFilter.all,
            label: TaskFilter.all.label,
            count: allCount,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            filter: TaskFilter.active,
            label: TaskFilter.active.label,
            count: activeCount,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            filter: TaskFilter.completed,
            label: TaskFilter.completed.label,
            count: completedCount,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  /// Build a single filter chip
  Widget _buildFilterChip({
    required BuildContext context,
    required TaskFilter filter,
    required String label,
    required int count,
    required ColorScheme colorScheme,
  }) {
    final isSelected = currentFilter == filter;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.onPrimaryContainer.withOpacity(0.2)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      onSelected: (_) => onFilterChanged(filter),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      side: BorderSide(
        color: isSelected 
            ? colorScheme.primary 
            : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
