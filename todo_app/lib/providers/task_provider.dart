import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

/// Task Provider
/// 
/// Manages the state of all tasks using Provider pattern.
/// Handles CRUD operations and persists data to local storage.
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isLoading = false;
  String? _error;

  // UUID generator for creating unique task IDs
  final _uuid = const Uuid();

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  TaskFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get filtered tasks based on current filter
  List<Task> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.active:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
    }
  }

  /// Get count of active (incomplete) tasks
  int get activeTaskCount => _tasks.where((task) => !task.isCompleted).length;

  /// Get count of completed tasks
  int get completedTaskCount => _tasks.where((task) => task.isCompleted).length;

  /// Get total task count
  int get totalTaskCount => _tasks.length;

  /// Load tasks from local storage
  /// Call this when the app starts
  Future<void> loadTasks() async {
    _setLoading(true);
    _clearError();
    
    try {
      final loadedTasks = await StorageService.loadTasks();
      _tasks.clear();
      _tasks.addAll(loadedTasks);
      // Sort by creation date (newest first)
      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _setError('加载任务失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new task
  /// 
  /// [title] - The task description
  /// [dueDate] - Optional due date
  Future<void> addTask(String title, {DateTime? dueDate}) async {
    if (title.trim().isEmpty) {
      _setError('任务标题不能为空');
      return;
    }

    final newTask = Task(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );

    _tasks.insert(0, newTask); // Add to beginning of list
    _clearError();
    notifyListeners();
    
    await _persistTasks();
  }

  /// Toggle task completion status
  /// 
  /// [taskId] - The ID of the task to toggle
  Future<void> toggleTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(
      isCompleted: !_tasks[index].isCompleted,
    );
    notifyListeners();
    
    await _persistTasks();
  }

  /// Delete a task
  /// 
  /// [taskId] - The ID of the task to delete
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
    
    await _persistTasks();
  }

  /// Edit a task's title
  /// 
  /// [taskId] - The ID of the task to edit
  /// [newTitle] - The new title for the task
  Future<void> editTask(String taskId, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _setError('任务标题不能为空');
      return;
    }

    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;

    _tasks[index] = _tasks[index].copyWith(title: newTitle.trim());
    _clearError();
    notifyListeners();
    
    await _persistTasks();
  }

  /// Set the current filter
  /// 
  /// [filter] - The filter to apply to the task list
  void setFilter(TaskFilter filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    notifyListeners();
  }

  /// Clear all completed tasks
  Future<void> clearCompleted() async {
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();
    
    await _persistTasks();
  }

  /// Clear all tasks
  Future<void> clearAll() async {
    _tasks.clear();
    notifyListeners();
    
    await _persistTasks();
  }

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _persistTasks() async {
    try {
      await StorageService.saveTasks(_tasks);
    } catch (e) {
      _setError('保存任务失败: $e');
    }
  }
}
