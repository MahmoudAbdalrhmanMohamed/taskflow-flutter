import 'package:intl/intl.dart';

class TaskProjectSummary {
  final String id;
  final String name;
  final String color;

  TaskProjectSummary({
    required this.id,
    required this.name,
    required this.color,
  });

  factory TaskProjectSummary.fromJson(Map<String, dynamic> json) {
    return TaskProjectSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#6366F1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String status; // 'TODO', 'IN_PROGRESS', 'DONE'
  final String priority; // 'LOW', 'MEDIUM', 'HIGH'
  final DateTime? dueDate;
  final int order;
  final String projectId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TaskProjectSummary? project;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.status = 'TODO',
    this.priority = 'MEDIUM',
    this.dueDate,
    this.order = 0,
    required this.projectId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.project,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'TODO',
      priority: json['priority'] as String? ?? 'MEDIUM',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      order: json['order'] as int? ?? 0,
      projectId: json['projectId'] as String,
      userId: json['userId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      project: json['project'] != null
          ? TaskProjectSummary.fromJson(json['project'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'order': order,
      'projectId': projectId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'project': project?.toJson(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    int? order,
    String? projectId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    TaskProjectSummary? project,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      order: order ?? this.order,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      project: project ?? this.project,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == 'DONE') return false;
    return dueDate!.isBefore(DateTime.now());
  }

  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    return DateFormat('MMM d, y').format(dueDate!);
  }
}
