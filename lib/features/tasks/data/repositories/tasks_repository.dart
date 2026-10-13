import '../../../../core/network/api_client.dart';
import '../models/task_model.dart';

class TasksRepository {
  final ApiClient _apiClient;

  TasksRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<TaskModel>> getTasks({
    String? projectId,
    String? status,
    String? priority,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      if (projectId != null && projectId.isNotEmpty) 'projectId': projectId,
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
    };

    final response = await _apiClient.get(
      '/tasks',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final list = response.data as List;
    return list.map((item) => TaskModel.fromJson(item)).toList();
  }

  Future<TaskModel> getTask(String id) async {
    final response = await _apiClient.get('/tasks/$id');
    return TaskModel.fromJson(response.data);
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    int? order,
    required String projectId,
  }) async {
    final response = await _apiClient.post(
      '/tasks',
      data: {
        'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (order != null) 'order': order,
        'projectId': projectId,
      },
    );
    return TaskModel.fromJson(response.data);
  }

  Future<TaskModel> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    int? order,
    String? projectId,
  }) async {
    final response = await _apiClient.patch(
      '/tasks/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (order != null) 'order': order,
        if (projectId != null) 'projectId': projectId,
      },
    );
    return TaskModel.fromJson(response.data);
  }

  Future<void> deleteTask(String id) async {
    await _apiClient.delete('/tasks/$id');
  }
}
