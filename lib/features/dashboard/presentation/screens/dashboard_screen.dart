import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authState.user;
    final stats = dashboardState.stats;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('TaskFlow'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(dashboardProvider.notifier).fetchStats(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).fetchStats(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.name ?? 'Alex'} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Loading or Error State
              if (dashboardState.isLoading && stats == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (stats != null) ...[
                // Stat Cards Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    final crossAxisCount = isWide ? 4 : 2;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.4 : 1.25,
                      children: [
                        StatCard(
                          title: 'Total Projects',
                          value: '${stats.totalProjects}',
                          icon: Icons.folder_rounded,
                          accentColor: AppColors.primary,
                          subtitle: 'Active workspaces',
                        ),
                        StatCard(
                          title: 'Completed',
                          value: '${stats.completedTasks}',
                          icon: Icons.check_circle_rounded,
                          accentColor: AppColors.statusDone,
                          subtitle: '${stats.completionRate}% completion rate',
                        ),
                        StatCard(
                          title: 'In Progress',
                          value: '${stats.inProgressTasks}',
                          icon: Icons.pending_rounded,
                          accentColor: AppColors.statusInProgress,
                          subtitle: '${stats.todoTasks} in backlog',
                        ),
                        StatCard(
                          title: 'Overdue Tasks',
                          value: '${stats.overdueTasks}',
                          icon: Icons.warning_amber_rounded,
                          accentColor: AppColors.priorityHigh,
                          subtitle: stats.overdueTasks > 0 ? 'Requires attention' : 'All on track',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Overall Completion Progress Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sprint & Workflow Progress',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${stats.completionRate}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: stats.completionRate / 100,
                          minHeight: 10,
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Priority Distribution Badges
                      Row(
                        children: [
                          _buildPriorityBadge(
                            'High Priority',
                            '${stats.tasksByPriority['high'] ?? 0}',
                            AppColors.priorityHigh,
                          ),
                          const SizedBox(width: 8),
                          _buildPriorityBadge(
                            'Medium',
                            '${stats.tasksByPriority['medium'] ?? 0}',
                            AppColors.priorityMedium,
                          ),
                          const SizedBox(width: 8),
                          _buildPriorityBadge(
                            'Low',
                            '${stats.tasksByPriority['low'] ?? 0}',
                            AppColors.priorityLow,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upcoming Deadlines Section
                const Text(
                  'Upcoming Deadlines',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (stats.upcomingDeadlines.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🎉 No upcoming deadlines for the next 14 days!',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...stats.upcomingDeadlines.map((dl) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: dl.colorValue.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.timer_outlined, color: dl.colorValue, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dl.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dl.projectName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: dl.colorValue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PriorityChip(priority: dl.priority, isSmall: true),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('MMM d').format(dl.dueDate),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // Recent Activity Timeline
                const Text(
                  'Recent Team Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: stats.recentActivities.isEmpty
                      ? const Center(
                          child: Text('No activity yet', style: TextStyle(color: Colors.grey)),
                        )
                      : Column(
                          children: stats.recentActivities.map((act) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: (act.type == 'task_completed'
                                              ? AppColors.statusDone
                                              : AppColors.primary)
                                          .withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      act.type == 'task_completed'
                                          ? Icons.check_rounded
                                          : Icons.edit_note_rounded,
                                      size: 16,
                                      color: act.type == 'task_completed'
                                          ? AppColors.statusDone
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          act.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (act.metadata != null)
                                          Text(
                                            act.metadata!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.lightTextSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(act.timestamp),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 80),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
