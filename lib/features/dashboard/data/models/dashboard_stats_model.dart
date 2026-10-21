import 'package:flutter/material.dart';

class UpcomingDeadlineModel {
  final String id;
  final String title;
  final DateTime dueDate;
  final String priority;
  final String status;
  final String projectName;
  final String projectColor;

  UpcomingDeadlineModel({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.projectName,
    required this.projectColor,
  });

  factory UpcomingDeadlineModel.fromJson(Map<String, dynamic> json) {
    return UpcomingDeadlineModel(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: json['priority'] as String? ?? 'MEDIUM',
      status: json['status'] as String? ?? 'TODO',
      projectName: json['projectName'] as String? ?? '',
      projectColor: json['projectColor'] as String? ?? '#6366F1',
    );
  }

  Color get colorValue {
    try {
      final clean = projectColor.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}

class RecentActivityModel {
  final String id;
  final String type;
  final String title;
  final DateTime timestamp;
  final String? metadata;

  RecentActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.timestamp,
    this.metadata,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as String?,
    );
  }
}

class ProjectSummaryModel {
  final String id;
  final String name;
  final String color;
  final int totalTasks;
  final int completedTasks;
  final int progressPercentage;

  ProjectSummaryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.totalTasks,
    required this.completedTasks,
    required this.progressPercentage,
  });

  factory ProjectSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProjectSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#6366F1',
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      progressPercentage: json['progressPercentage'] as int? ?? 0,
    );
  }

  Color get colorValue {
    try {
      final clean = color.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }
}

class DashboardStatsModel {
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int todoTasks;
  final int overdueTasks;
  final int completionRate;
  final Map<String, int> tasksByPriority;
  final List<UpcomingDeadlineModel> upcomingDeadlines;
  final List<RecentActivityModel> recentActivities;
  final List<ProjectSummaryModel> projectSummaries;

  DashboardStatsModel({
    required this.totalProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.todoTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.tasksByPriority,
    required this.upcomingDeadlines,
    required this.recentActivities,
    required this.projectSummaries,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final priorityMap = json['tasksByPriority'] as Map<String, dynamic>? ?? {};
    final deadlinesList = json['upcomingDeadlines'] as List? ?? [];
    final activitiesList = json['recentActivities'] as List? ?? [];
    final projectsList = json['projectSummaries'] as List? ?? [];

    return DashboardStatsModel(
      totalProjects: json['totalProjects'] as int? ?? 0,
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      inProgressTasks: json['inProgressTasks'] as int? ?? 0,
      todoTasks: json['todoTasks'] as int? ?? 0,
      overdueTasks: json['overdueTasks'] as int? ?? 0,
      completionRate: json['completionRate'] as int? ?? 0,
      tasksByPriority: {
        'low': priorityMap['low'] as int? ?? 0,
        'medium': priorityMap['medium'] as int? ?? 0,
        'high': priorityMap['high'] as int? ?? 0,
      },
      upcomingDeadlines: deadlinesList
          .map((item) => UpcomingDeadlineModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      recentActivities: activitiesList
          .map((item) => RecentActivityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      projectSummaries: projectsList
          .map((item) => ProjectSummaryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory DashboardStatsModel.empty() {
    return DashboardStatsModel(
      totalProjects: 0,
      totalTasks: 0,
      completedTasks: 0,
      inProgressTasks: 0,
      todoTasks: 0,
      overdueTasks: 0,
      completionRate: 0,
      tasksByPriority: const {'low': 0, 'medium': 0, 'high': 0},
      upcomingDeadlines: const [],
      recentActivities: const [],
      projectSummaries: const [],
    );
  }
}
