import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/widgets/task_form_dialog.dart';
import '../../data/models/project_model.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_form_dialog.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  String _selectedStatusFilter = 'ALL';

  void _showAddTaskDialog(ProjectModel project) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(
        defaultProjectId: project.id,
        onSave: ({
          required title,
          description,
          status,
          priority,
          dueDate,
          required projectId,
        }) async {
          await ref.read(tasksProvider.notifier).createTask(
                title: title,
                description: description,
                status: status,
                priority: priority,
                dueDate: dueDate,
                projectId: projectId,
              );
        },
      ),
    );
  }

  void _showEditProjectDialog(ProjectModel project) {
    showDialog(
      context: context,
      builder: (ctx) => ProjectFormDialog(
        project: project,
        onSave: ({required name, description, color, icon, status}) async {
          await ref.read(projectsProvider.notifier).updateProject(
                project.id,
                name: name,
                description: description,
                color: color,
                icon: icon,
                status: status,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);
    final tasksState = ref.watch(tasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final project = projectsState.projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => ProjectModel(
        id: widget.projectId,
        name: 'Project Details',
        ownerId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        stats: ProjectStatsModel(
          totalTasks: 0,
          completedTasks: 0,
          inProgressTasks: 0,
          todoTasks: 0,
          progressPercentage: 0,
        ),
      ),
    );

    final projectTasks = tasksState.tasks.where((t) {
      if (t.projectId != widget.projectId) return false;
      if (_selectedStatusFilter == 'ALL') return true;
      return t.status == _selectedStatusFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/projects'),
        ),
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProjectDialog(project),
            tooltip: 'Edit Project',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
            onPressed: () {
              ref.read(projectsProvider.notifier).deleteProject(project.id);
              context.go('/projects');
            },
            tooltip: 'Delete Project',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(project),
        backgroundColor: project.colorValue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Overview Card
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: project.colorValue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          project.iconData,
                          size: 26,
                          color: project.colorValue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (project.description != null &&
                                project.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                project.description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar & Percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completion Progress',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '${project.stats.progressPercentage}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: project.colorValue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: project.stats.totalTasks > 0
                          ? project.stats.progressPercentage / 100
                          : 0,
                      minHeight: 8,
                      backgroundColor: project.colorValue.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(project.colorValue),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('Total', project.stats.totalTasks.toString(), Colors.grey),
                      _buildMiniStat('To Do', project.stats.todoTasks.toString(), AppColors.statusTodo),
                      _buildMiniStat('In Progress', project.stats.inProgressTasks.toString(), AppColors.statusInProgress),
                      _buildMiniStat('Done', project.stats.completedTasks.toString(), AppColors.statusDone),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Header & Status Filters
            Row(
              children: [
                const Text(
                  'Project Tasks',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedStatusFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'TODO', child: Text('To Do')),
                    DropdownMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
                    DropdownMenuItem(value: 'DONE', child: Text('Done')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatusFilter = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tasks List
            if (projectTasks.isEmpty)
              EmptyStateWidget(
                icon: Icons.checklist_rounded,
                title: 'No Tasks in this Project',
                description: 'Add tasks to start tracking progress on this project.',
                buttonText: 'Add Task',
                onButtonPressed: () => _showAddTaskDialog(project),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projectTasks.length,
                itemBuilder: (context, index) {
                  final task = projectTasks[index];
                  return TaskCard(
                    task: task,
                    onStatusChanged: (newStatus) {
                      ref
                          .read(tasksProvider.notifier)
                          .updateTaskStatus(task.id, newStatus);
                    },
                    onDelete: () {
                      ref.read(tasksProvider.notifier).deleteTask(task.id);
                    },
                  );
                },
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
