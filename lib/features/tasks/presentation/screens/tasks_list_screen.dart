import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';
import '../../data/models/task_model.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTaskDialog([TaskModel? task]) {
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
          if (task != null) {
            await ref.read(tasksProvider.notifier).updateTask(
                  task.id,
                  title: title,
                  description: description,
                  status: status,
                  priority: priority,
                  dueDate: dueDate,
                  projectId: projectId,
                );
          } else {
            await ref.read(tasksProvider.notifier).createTask(
                  title: title,
                  description: description,
                  status: status,
                  priority: priority,
                  dueDate: dueDate,
                  projectId: projectId,
                );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final projectsState = ref.watch(projectsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = tasksState.filter;
    final filteredTasks = tasksState.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () => ref.read(tasksProvider.notifier).fetchTasks(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(tasksProvider.notifier).fetchTasks(),
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(tasksProvider.notifier).updateSearch(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search tasks by title or details...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(tasksProvider.notifier).updateSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Horizontal Filter Chips (Status & Project)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Status Filters
                  ChoiceChip(
                    label: const Text('All'),
                    selected: filter.status == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(tasksProvider.notifier).setFilter(
                              filter.copyWith(clearStatus: true),
                            );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('To Do'),
                    selected: filter.status == 'TODO',
                    onSelected: (selected) {
                      ref.read(tasksProvider.notifier).setFilter(
                            filter.copyWith(status: selected ? 'TODO' : null),
                          );
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('In Progress'),
                    selected: filter.status == 'IN_PROGRESS',
                    onSelected: (selected) {
                      ref.read(tasksProvider.notifier).setFilter(
                            filter.copyWith(status: selected ? 'IN_PROGRESS' : null),
                          );
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Done'),
                    selected: filter.status == 'DONE',
                    onSelected: (selected) {
                      ref.read(tasksProvider.notifier).setFilter(
                            filter.copyWith(status: selected ? 'DONE' : null),
                          );
                    },
                  ),
                  const SizedBox(width: 14),
                  Container(width: 1, height: 24, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  const SizedBox(width: 14),

                  // Project Filter Dropdown
                  PopupMenuButton<String?>(
                    child: Chip(
                      avatar: const Icon(Icons.folder_outlined, size: 16),
                      label: Text(
                        filter.projectId == null
                            ? 'All Projects'
                            : (projectsState.projects
                                    .firstWhere(
                                      (p) => p.id == filter.projectId,
                                      orElse: () => projectsState.projects.first,
                                    )
                                    .name),
                      ),
                      deleteIcon: filter.projectId != null ? const Icon(Icons.close, size: 14) : null,
                      onDeleted: filter.projectId != null
                          ? () {
                              ref.read(tasksProvider.notifier).setFilter(
                                    filter.copyWith(clearProject: true),
                                  );
                            }
                          : null,
                    ),
                    onSelected: (id) {
                      ref.read(tasksProvider.notifier).setFilter(
                            id == null
                                ? filter.copyWith(clearProject: true)
                                : filter.copyWith(projectId: id),
                          );
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: null,
                        child: Text('All Projects'),
                      ),
                      ...projectsState.projects.map((p) {
                        return PopupMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            // Tasks List
            Expanded(
              child: tasksState.isLoading && tasksState.tasks.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredTasks.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.checklist_rounded,
                          title: 'No Tasks Found',
                          description: filter.searchQuery.isNotEmpty || filter.status != null
                              ? 'Try adjusting your search filters or status criteria.'
                              : 'Create your first task to start organizing your workflow.',
                          buttonText: 'Create Task',
                          onButtonPressed: () => _showTaskDialog(),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskCard(
                              task: task,
                              onEdit: () => _showTaskDialog(task),
                              onDelete: () {
                                ref.read(tasksProvider.notifier).deleteTask(task.id);
                              },
                              onStatusChanged: (newStatus) {
                                ref
                                    .read(tasksProvider.notifier)
                                    .updateTaskStatus(task.id, newStatus);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
