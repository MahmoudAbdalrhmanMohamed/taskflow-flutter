import '../../features/dashboard/data/models/dashboard_stats_model.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/data/models/task_model.dart';

class DemoData {
  static final DateTime now = DateTime.now();

  static List<ProjectModel> get projects => [
        ProjectModel(
          id: 'proj-1',
          name: 'TaskFlow Mobile & Web App',
          description:
              'Cross-platform Flutter application with Riverpod, GoRouter and Kanban workflow.',
          color: '#6366F1',
          icon: 'smartphone',
          status: 'active',
          ownerId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 14)),
          updatedAt: now.subtract(const Duration(days: 1)),
          stats: ProjectStatsModel(
            totalTasks: 4,
            completedTasks: 2,
            inProgressTasks: 1,
            todoTasks: 1,
            progressPercentage: 50,
          ),
        ),
        ProjectModel(
          id: 'proj-2',
          name: 'NestJS Cloud API & Microservices',
          description:
              'Enterprise NestJS REST API with Prisma ORM, PostgreSQL, JWT auth, and Swagger documentation.',
          color: '#10B981',
          icon: 'server',
          status: 'active',
          ownerId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 20)),
          updatedAt: now.subtract(const Duration(days: 2)),
          stats: ProjectStatsModel(
            totalTasks: 3,
            completedTasks: 1,
            inProgressTasks: 1,
            todoTasks: 1,
            progressPercentage: 33,
          ),
        ),
        ProjectModel(
          id: 'proj-3',
          name: 'Design System & UI Components',
          description:
              'Modern Material 3 dark/light design system, responsive dashboards, and interactive Kanban boards.',
          color: '#F59E0B',
          icon: 'palette',
          status: 'active',
          ownerId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 3)),
          stats: ProjectStatsModel(
            totalTasks: 2,
            completedTasks: 1,
            inProgressTasks: 1,
            todoTasks: 0,
            progressPercentage: 50,
          ),
        ),
      ];

  static List<TaskModel> get tasks => [
        TaskModel(
          id: 'task-1',
          title: 'Direct Login Navigation Guard',
          description:
              'Ensure unauthenticated users land immediately on login screen without flashing home.',
          status: 'DONE',
          priority: 'HIGH',
          dueDate: now.subtract(const Duration(days: 1)),
          order: 0,
          projectId: 'proj-1',
          userId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now,
          project: TaskProjectSummary(
            id: 'proj-1',
            name: 'TaskFlow Mobile & Web App',
            color: '#6366F1',
          ),
        ),
        TaskModel(
          id: 'task-2',
          title: 'Implement Interactive Kanban Board',
          description:
              'Support drag-and-drop and one-tap column moves across TODO, IN_PROGRESS, and DONE.',
          status: 'DONE',
          priority: 'HIGH',
          dueDate: now.subtract(const Duration(days: 2)),
          order: 1,
          projectId: 'proj-1',
          userId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 1)),
          project: TaskProjectSummary(
            id: 'proj-1',
            name: 'TaskFlow Mobile & Web App',
            color: '#6366F1',
          ),
        ),
        TaskModel(
          id: 'task-3',
          title: 'Prisma PostgreSQL Schema & Migrations',
          description:
              'Configure Prisma client, seed data, and connection pooling for Neon PostgreSQL.',
          status: 'IN_PROGRESS',
          priority: 'HIGH',
          dueDate: now.add(const Duration(days: 2)),
          order: 0,
          projectId: 'proj-2',
          userId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 4)),
          updatedAt: now,
          project: TaskProjectSummary(
            id: 'proj-2',
            name: 'NestJS Cloud API & Microservices',
            color: '#10B981',
          ),
        ),
        TaskModel(
          id: 'task-4',
          title: 'Responsive Dashboard Analytics Widget',
          description:
              'Aggregate sprint completion percentages and priority distribution charts.',
          status: 'IN_PROGRESS',
          priority: 'MEDIUM',
          dueDate: now.add(const Duration(days: 4)),
          order: 1,
          projectId: 'proj-1',
          userId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now,
          project: TaskProjectSummary(
            id: 'proj-1',
            name: 'TaskFlow Mobile & Web App',
            color: '#6366F1',
          ),
        ),
        TaskModel(
          id: 'task-5',
          title: 'Dark / Light Theme Token Unification',
          description:
              'Ensure seamless contrast and smooth transition between dark and light themes.',
          status: 'DONE',
          priority: 'LOW',
          dueDate: now.subtract(const Duration(days: 3)),
          order: 0,
          projectId: 'proj-3',
          userId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 7)),
          updatedAt: now.subtract(const Duration(days: 2)),
          project: TaskProjectSummary(
            id: 'proj-3',
            name: 'Design System & UI Components',
            color: '#F59E0B',
          ),
        ),
        TaskModel(
          id: 'task-6',
          title: 'JWT Authentication & Refresh Strategy',
          description:
              'Stateless Bearer JWT tokens with secure storage persistence and automatic invalidation.',
          status: 'TODO',
          priority: 'MEDIUM',
          dueDate: now.add(const Duration(days: 6)),
          order: 0,
          projectId: 'proj-2',
          userId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
          project: TaskProjectSummary(
            id: 'proj-2',
            name: 'NestJS Cloud API & Microservices',
            color: '#10B981',
          ),
        ),
        TaskModel(
          id: 'task-7',
          title: 'Multi-Platform CI/CD Validation Pipeline',
          description:
              'Automated GitHub Actions checks for Flutter test suite and NestJS unit/e2e specs.',
          status: 'TODO',
          priority: 'LOW',
          dueDate: now.add(const Duration(days: 8)),
          order: 1,
          projectId: 'proj-1',
          userId: 'demo-user-id',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
          project: TaskProjectSummary(
            id: 'proj-1',
            name: 'TaskFlow Mobile & Web App',
            color: '#6366F1',
          ),
        ),
      ];

  static DashboardStatsModel get stats => DashboardStatsModel(
        totalProjects: 3,
        totalTasks: 7,
        completedTasks: 3,
        inProgressTasks: 2,
        todoTasks: 2,
        overdueTasks: 0,
        completionRate: 43,
        tasksByPriority: {
          'low': 2,
          'medium': 2,
          'high': 3,
        },
        upcomingDeadlines: [
          UpcomingDeadlineModel(
            id: 'task-3',
            title: 'Prisma PostgreSQL Schema & Migrations',
            dueDate: now.add(const Duration(days: 2)),
            priority: 'HIGH',
            status: 'IN_PROGRESS',
            projectName: 'NestJS Cloud API & Microservices',
            projectColor: '#10B981',
          ),
          UpcomingDeadlineModel(
            id: 'task-4',
            title: 'Responsive Dashboard Analytics Widget',
            dueDate: now.add(const Duration(days: 4)),
            priority: 'MEDIUM',
            status: 'IN_PROGRESS',
            projectName: 'TaskFlow Mobile & Web App',
            projectColor: '#6366F1',
          ),
          UpcomingDeadlineModel(
            id: 'task-6',
            title: 'JWT Authentication & Refresh Strategy',
            dueDate: now.add(const Duration(days: 6)),
            priority: 'MEDIUM',
            status: 'TODO',
            projectName: 'NestJS Cloud API & Microservices',
            projectColor: '#10B981',
          ),
        ],
        recentActivities: [
          RecentActivityModel(
            id: 'act-1',
            type: 'task_completed',
            title: 'Completed Direct Login Navigation Guard',
            timestamp: now.subtract(const Duration(minutes: 15)),
            metadata: 'TaskFlow Mobile & Web App',
          ),
          RecentActivityModel(
            id: 'act-2',
            type: 'task_created',
            title: 'Moved Prisma PostgreSQL Schema to In Progress',
            timestamp: now.subtract(const Duration(hours: 2)),
            metadata: 'NestJS Cloud API & Microservices',
          ),
          RecentActivityModel(
            id: 'act-3',
            type: 'task_completed',
            title: 'Completed Dark / Light Theme Token Unification',
            timestamp: now.subtract(const Duration(hours: 5)),
            metadata: 'Design System & UI Components',
          ),
        ],
        projectSummaries: [
          ProjectSummaryModel(
            id: 'proj-1',
            name: 'TaskFlow Mobile & Web App',
            color: '#6366F1',
            totalTasks: 4,
            completedTasks: 2,
            progressPercentage: 50,
          ),
          ProjectSummaryModel(
            id: 'proj-2',
            name: 'NestJS Cloud API & Microservices',
            color: '#10B981',
            totalTasks: 3,
            completedTasks: 1,
            progressPercentage: 33,
          ),
          ProjectSummaryModel(
            id: 'proj-3',
            name: 'Design System & UI Components',
            color: '#F59E0B',
            totalTasks: 2,
            completedTasks: 1,
            progressPercentage: 50,
          ),
        ],
      );
}
