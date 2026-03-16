import 'package:flutter/material.dart';

/// Empty State Widget
/// 
/// Displays a friendly message when there are no tasks to show
class EmptyState extends StatelessWidget {
  final bool isFiltered;

  const EmptyState({
    super.key,
    this.isFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.filter_list_off : Icons.check_circle_outline,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              isFiltered ? '没有符合条件的任务' : '还没有任务',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              isFiltered
                  ? '尝试切换其他筛选条件查看任务'
                  : '点击右下角的按钮添加你的第一个任务吧！',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
