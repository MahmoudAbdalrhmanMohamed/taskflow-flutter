import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/projects_repository.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProjectsRepository(apiClient: apiClient);
});

class ProjectsState {
  final List<ProjectModel> projects;
  final bool isLoading;
  final String? error;

  const ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ProjectsState copyWith({
    List<ProjectModel>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final ProjectsRepository _repository;

  ProjectsNotifier(this._repository) : super(const ProjectsState()) {
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _repository.getProjects();
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createProject({
    required String name,
    String? description,
    String? color,
    String? icon,
    String? status,
  }) async {
    try {
      final newProject = await _repository.createProject(
        name: name,
        description: description,
        color: color,
        icon: icon,
        status: status,
      );
      state = state.copyWith(
        projects: [newProject, ...state.projects],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateProject(
    String id, {
    String? name,
    String? description,
    String? color,
    String? icon,
    String? status,
  }) async {
    try {
      final updated = await _repository.updateProject(
        id,
        name: name,
        description: description,
        color: color,
        icon: icon,
        status: status,
      );
      state = state.copyWith(
        projects: state.projects.map((p) => p.id == id ? updated : p).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      await _repository.deleteProject(id);
      state = state.copyWith(
        projects: state.projects.where((p) => p.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  final repo = ref.watch(projectsRepositoryProvider);
  return ProjectsNotifier(repo);
});
