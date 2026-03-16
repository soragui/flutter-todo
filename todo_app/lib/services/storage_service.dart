import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// Storage Service
/// Handles local persistence of tasks using SharedPreferences
/// 
/// This service abstracts the storage implementation and provides
/// a clean API for saving and loading tasks.
class StorageService {
  static const String _tasksKey = 'tasks';
  
  /// Save tasks to local storage
  /// 
  /// Converts the list of tasks to JSON and stores it in SharedPreferences
  static Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = tasks.map((task) => task.toJson()).toList();
      final tasksString = jsonEncode(tasksJson);
      await prefs.setString(_tasksKey, tasksString);
    } catch (e) {
      throw Exception('Failed to save tasks: $e');
    }
  }

  /// Load tasks from local storage
  /// 
  /// Returns an empty list if no tasks are found or if there's an error
  static Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksString = prefs.getString(_tasksKey);
      
      if (tasksString == null || tasksString.isEmpty) {
        return [];
      }
      
      final tasksJson = jsonDecode(tasksString) as List<dynamic>;
      return tasksJson
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list on error to prevent app crash
      return [];
    }
  }

  /// Clear all tasks from storage
  static Future<void> clearTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
    } catch (e) {
      throw Exception('Failed to clear tasks: $e');
    }
  }
}
