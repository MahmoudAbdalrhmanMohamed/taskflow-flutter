import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';

void main() {
  group('TaskFlow Models Serialization Tests', () {
    test('UserModel fromJson and initials calculation', () {
      final json = {
        'id': 'user-1',
        'email': 'alex@taskflow.dev',
        'name': 'Alex Morgan',
        'jobTitle': 'Lead Architect',
        'department': 'Engineering',
        'createdAt': '2026-10-13T12:00:00.000Z',
        'updatedAt': '2026-10-13T12:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.email, 'alex@taskflow.dev');
      expect(user.name, 'Alex Morgan');
      expect(user.initials, 'AM');
    });

    test('ProjectModel fromJson and stats calculation', () {
      final json = {
        'id': 'project-1',
        'name': 'TaskFlow Flutter',
        'color': '#6366F1',
        'icon': 'smartphone',
        'status': 'active',
        'ownerId': 'user-1',
        'createdAt': '2026-10-13T12:00:00.000Z',
        'updatedAt': '2026-10-13T12:00:00.000Z',
        'stats': {
          'totalTasks': 10,
          'completedTasks': 7,
          'inProgressTasks': 2,
          'todoTasks': 1,
          'progressPercentage': 70,
        },
      };

      final project = ProjectModel.fromJson(json);

      expect(project.name, 'TaskFlow Flutter');
      expect(project.stats.totalTasks, 10);
      expect(project.stats.completedTasks, 7);
      expect(project.stats.progressPercentage, 70);
    });

    test('TaskModel fromJson and overdue status', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final json = {
        'id': 'task-1',
        'title': 'Overdue Task',
        'status': 'TODO',
        'priority': 'HIGH',
        'dueDate': pastDate.toIso8601String(),
        'order': 0,
        'projectId': 'project-1',
        'userId': 'user-1',
        'createdAt': pastDate.toIso8601String(),
        'updatedAt': pastDate.toIso8601String(),
      };

      final task = TaskModel.fromJson(json);

      expect(task.title, 'Overdue Task');
      expect(task.isOverdue, isTrue);
      expect(task.status, 'TODO');
      expect(task.priority, 'HIGH');
    });
  });
}
