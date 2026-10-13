import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/projects_provider.dart';
import '../widgets/project_form_dialog.dart';
import '../../data/models/project_model.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProjectDialog([ProjectModel? project]) {
    showDialog(
      context: context,
      builder: (ctx) => ProjectFormDialog(
        project: project,
        onSave: ({required name, description, color, icon, status}) async {
          if (project != null) {
            await ref.read(projectsProvider.notifier).updateProject(
                  project.id,
                  name: name,
                  description: description,
                  color: color,
                  icon: icon,
                  status: status,
                );
          } else {
            await ref.read(projectsProvider.notifier).createProject(
                  name: name,
                  description: description,
                  color: color,
                  icon: icon,
                  status: status,
                );
          }
        },
      ),
    );
  }

  void _confirmDelete(ProjectModel project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? All associated tasks will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityHigh),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(projectsProvider.notifier).deleteProject(project.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredProjects = state.projects.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: () => ref.read(projectsProvider.notifier).fetchProjects(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Project', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(projectsProvider.notifier).fetchProjects(),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            Expanded(
              child: state.isLoading && state.projects.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProjects.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.folder_open_rounded,
                          title: _searchQuery.isEmpty ? 'No Projects Yet' : 'No Projects Found',
                          description: _searchQuery.isEmpty
                              ? 'Organize your team goals and workflows by creating your first project.'
                              : 'No projects match "$_searchQuery". Try another keyword.',
                          buttonText: _searchQuery.isEmpty ? 'Create Project' : null,
                          onButtonPressed: _searchQuery.isEmpty ? () => _showProjectDialog() : null,
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 900
                                ? 3
                                : (constraints.maxWidth > 600 ? 2 : 1);

                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 175,
                              ),
                              itemCount: filteredProjects.length,
                              itemBuilder: (context, index) {
                                final project = filteredProjects[index];
                                return _buildProjectCard(project, isDark);
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

  Widget _buildProjectCard(ProjectModel project, bool isDark) {
    final progress = project.stats.progressPercentage;

    return InkWell(
      onTap: () => context.go('/projects/${project.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: project.colorValue.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    project.iconData,
                    color: project.colorValue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        project.description ?? 'No description provided',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _showProjectDialog(project);
                    } else if (val == 'delete') {
                      _confirmDelete(project);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.priorityHigh),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.priorityHigh)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Progress Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${project.stats.completedTasks}/${project.stats.totalTasks} Tasks Done',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: project.colorValue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: project.stats.totalTasks > 0 ? progress / 100 : 0,
                    minHeight: 6,
                    backgroundColor: project.colorValue.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(project.colorValue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
