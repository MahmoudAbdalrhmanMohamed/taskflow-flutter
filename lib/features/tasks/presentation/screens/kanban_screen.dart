import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';
import '../../data/models/task_model.dart';

class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key});

  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateTaskDialog(String status) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(
        defaultStatus: status,
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

  void _showEditTaskDialog(TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => TaskFormDialog(
        task: task,
        onSave: ({
          required title,
          description,
          status,
          priority,
          dueDate,
          required projectId,
        }) async {
          await ref.read(tasksProvider.notifier).updateTask(
                task.id,
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

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todoTasks = tasksState.todoTasks;
    final inProgressTasks = tasksState.inProgressTasks;
    final doneTasks = tasksState.doneTasks;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kanban Board'),
            actions: [
              IconButton(
                onPressed: () => ref.read(tasksProvider.notifier).fetchTasks(),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
            bottom: !isWide
                ? TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    labelColor: AppColors.primary,
                    unselectedLabelColor:
                        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    tabs: [
                      Tab(text: 'To Do (${todoTasks.length})'),
                      Tab(text: 'In Progress (${inProgressTasks.length})'),
                      Tab(text: 'Done (${doneTasks.length})'),
                    ],
                  )
                : null,
          ),
          body: isWide
              // Side-by-side columns on tablet / desktop
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildKanbanColumn(
                          title: 'To Do',
                          status: 'TODO',
                          tasks: todoTasks,
                          color: AppColors.statusTodo,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKanbanColumn(
                          title: 'In Progress',
                          status: 'IN_PROGRESS',
                          tasks: inProgressTasks,
                          color: AppColors.statusInProgress,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildKanbanColumn(
                          title: 'Done',
                          status: 'DONE',
                          tasks: doneTasks,
                          color: AppColors.statusDone,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                )
              // Tabbed view on mobile
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildKanbanColumn(
                      title: 'To Do',
                      status: 'TODO',
                      tasks: todoTasks,
                      color: AppColors.statusTodo,
                      isDark: isDark,
                    ),
                    _buildKanbanColumn(
                      title: 'In Progress',
                      status: 'IN_PROGRESS',
                      tasks: inProgressTasks,
                      color: AppColors.statusInProgress,
                      isDark: isDark,
                    ),
                    _buildKanbanColumn(
                      title: 'Done',
                      status: 'DONE',
                      tasks: doneTasks,
                      color: AppColors.statusDone,
                      isDark: isDark,
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required String status,
    required List<TaskModel> tasks,
    required Color color,
    required bool isDark,
  }) {
    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        final draggedTask = details.data;
        ref.read(tasksProvider.notifier).updateTaskStatus(draggedTask.id, status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Moved "${draggedTask.title}" to $title'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: isHovered
                ? color.withOpacity(0.08)
                : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered
                  ? color
                  : (isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder),
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Column Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 20),
                      onPressed: () => _showCreateTaskDialog(status),
                      tooltip: 'Add task to $title',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Tasks Scroll Area
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 36,
                                color: (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary)
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No tasks in $title',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Drag cards here',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return LongPressDraggable<TaskModel>(
                            data: task,
                            feedback: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(16),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 320),
                                child: TaskCard(task: task),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.35,
                              child: TaskCard(task: task),
                            ),
                            child: TaskCard(
                              task: task,
                              onEdit: () => _showEditTaskDialog(task),
                              onDelete: () {
                                ref.read(tasksProvider.notifier).deleteTask(task.id);
                              },
                              onStatusChanged: (newStatus) {
                                ref
                                    .read(tasksProvider.notifier)
                                    .updateTaskStatus(task.id, newStatus);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
