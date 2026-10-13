import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow/features/projects/presentation/providers/projects_provider.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/tasks_repository.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TasksRepository(apiClient: apiClient);
});

class TasksFilterState {
  final String? projectId;
  final String? status;
  final String? priority;
  final String searchQuery;
  final String sortBy;
  final String sortOrder;

  const TasksFilterState({
    this.projectId,
    this.status,
    this.priority,
    this.searchQuery = '',
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  TasksFilterState copyWith({
    String? projectId,
    String? status,
    String? priority,
    String? searchQuery,
    String? sortBy,
    String? sortOrder,
    bool clearProject = false,
    bool clearStatus = false,
    bool clearPriority = false,
  }) {
    return TasksFilterState(
      projectId: clearProject ? null : (projectId ?? this.projectId),
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class TasksState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;
  final TasksFilterState filter;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.filter = const TasksFilterState(),
  });

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? error,
    TasksFilterState? filter,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }

  List<TaskModel> get filteredTasks {
    return tasks.where((t) {
      if (filter.projectId != null && t.projectId != filter.projectId) {
        return false;
      }
      if (filter.status != null && t.status != filter.status) {
        return false;
      }
      if (filter.priority != null && t.priority != filter.priority) {
        return false;
      }
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final matchesTitle = t.title.toLowerCase().contains(query);
        final matchesDesc = t.description?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesDesc) return false;
      }
      return true;
    }).toList();
  }

  List<TaskModel> get todoTasks => tasks.where((t) => t.status == 'TODO').toList();
  List<TaskModel> get inProgressTasks => tasks.where((t) => t.status == 'IN_PROGRESS').toList();
  List<TaskModel> get doneTasks => tasks.where((t) => t.status == 'DONE').toList();
}

class TasksNotifier extends StateNotifier<TasksState> {
  final TasksRepository _repository;
  final Ref _ref;

  TasksNotifier(this._repository, this._ref) : super(const TasksState()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getTasks(
        projectId: state.filter.projectId,
        status: state.filter.status,
        priority: state.filter.priority,
        search: state.filter.searchQuery.isNotEmpty ? state.filter.searchQuery : null,
      );
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(TasksFilterState filter) {
    state = state.copyWith(filter: filter);
    fetchTasks();
  }

  void updateSearch(String query) {
    state = state.copyWith(
      filter: state.filter.copyWith(searchQuery: query),
    );
  }

  Future<bool> createTask({
    required String title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    int? order,
    required String projectId,
  }) async {
    try {
      final task = await _repository.createTask(
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        order: order,
        projectId: projectId,
      );
      state = state.copyWith(tasks: [task, ...state.tasks]);
      _ref.read(projectsProvider.notifier).fetchProjects();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    int? order,
    String? projectId,
  }) async {
    // Optimistic Update
    final originalTasks = List<TaskModel>.from(state.tasks);
    final taskIndex = state.tasks.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final old = state.tasks[taskIndex];
      final optimistic = old.copyWith(
        title: title ?? old.title,
        description: description ?? old.description,
        status: status ?? old.status,
        priority: priority ?? old.priority,
        dueDate: dueDate ?? old.dueDate,
        order: order ?? old.order,
        projectId: projectId ?? old.projectId,
      );
      final updatedList = List<TaskModel>.from(state.tasks);
      updatedList[taskIndex] = optimistic;
      state = state.copyWith(tasks: updatedList);
    }

    try {
      final updated = await _repository.updateTask(
        id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        order: order,
        projectId: projectId,
      );
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? updated : t).toList(),
      );
      _ref.read(projectsProvider.notifier).fetchProjects();
      return true;
    } catch (e) {
      // Revert optimistic update
      state = state.copyWith(tasks: originalTasks, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTaskStatus(String id, String newStatus) async {
    return updateTask(id, status: newStatus);
  }

  Future<bool> deleteTask(String id) async {
    final original = List<TaskModel>.from(state.tasks);
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
    );

    try {
      await _repository.deleteTask(id);
      _ref.read(projectsProvider.notifier).fetchProjects();
      return true;
    } catch (e) {
      state = state.copyWith(tasks: original, error: e.toString());
      return false;
    }
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return TasksNotifier(repo, ref);
});
