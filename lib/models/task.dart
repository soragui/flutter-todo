/// Task Model
/// Represents a single todo item with its properties
class Task {
  /// Unique identifier for the task
  final String id;
  
  /// Title/description of the task
  final String title;
  
  /// Whether the task is completed
  final bool isCompleted;
  
  /// Timestamp when the task was created
  final DateTime createdAt;
  
  /// Optional due date for the task
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
  });

  /// Create a copy of this task with modified fields
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  /// Convert Task to JSON for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  /// Create Task from JSON (from local storage)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'] as String) 
          : null,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}

/// Filter types for task list
enum TaskFilter {
  all('全部'),
  active('进行中'),
  completed('已完成');

  final String label;
  const TaskFilter(this.label);
}
