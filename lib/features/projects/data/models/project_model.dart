import 'package:flutter/material.dart';

class ProjectStatsModel {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int todoTasks;
  final int progressPercentage;

  ProjectStatsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.todoTasks,
    required this.progressPercentage,
  });

  factory ProjectStatsModel.fromJson(Map<String, dynamic> json) {
    return ProjectStatsModel(
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      inProgressTasks: json['inProgressTasks'] as int? ?? 0,
      todoTasks: json['todoTasks'] as int? ?? 0,
      progressPercentage: json['progressPercentage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'inProgressTasks': inProgressTasks,
      'todoTasks': todoTasks,
      'progressPercentage': progressPercentage,
    };
  }
}

class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String? icon;
  final String status;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectStatsModel stats;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.color = '#6366F1',
    this.icon = 'folder',
    this.status = 'active',
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.stats,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String? ?? '#6366F1',
      icon: json['icon'] as String? ?? 'folder',
      status: json['status'] as String? ?? 'active',
      ownerId: json['ownerId'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      stats: json['stats'] != null
          ? ProjectStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : ProjectStatsModel(
              totalTasks: 0,
              completedTasks: 0,
              inProgressTasks: 0,
              todoTasks: 0,
              progressPercentage: 0,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'status': status,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'stats': stats.toJson(),
    };
  }

  Color get colorValue {
    try {
      final hex = color.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF6366F1);
  }

  IconData get iconData {
    switch (icon) {
      case 'smartphone':
        return Icons.smartphone_rounded;
      case 'server':
        return Icons.dns_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'rocket':
        return Icons.rocket_launch_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'cloud':
        return Icons.cloud_queue_rounded;
      default:
        return Icons.folder_rounded;
    }
  }
}
