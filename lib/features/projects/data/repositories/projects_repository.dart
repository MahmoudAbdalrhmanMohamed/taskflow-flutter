import '../../../../core/network/api_client.dart';
import '../models/project_model.dart';

class ProjectsRepository {
  final ApiClient _apiClient;

  ProjectsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ProjectModel>> getProjects() async {
    final response = await _apiClient.get('/projects');
    final list = response.data as List;
    return list.map((item) => ProjectModel.fromJson(item)).toList();
  }

  Future<ProjectModel> getProject(String id) async {
    final response = await _apiClient.get('/projects/$id');
    return ProjectModel.fromJson(response.data);
  }

  Future<ProjectModel> createProject({
    required String name,
    String? description,
    String? color,
    String? icon,
    String? status,
  }) async {
    final response = await _apiClient.post(
      '/projects',
      data: {
        'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (status != null) 'status': status,
      },
    );
    return ProjectModel.fromJson(response.data);
  }

  Future<ProjectModel> updateProject(
    String id, {
    String? name,
    String? description,
    String? color,
    String? icon,
    String? status,
  }) async {
    final response = await _apiClient.patch(
      '/projects/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (status != null) 'status': status,
      },
    );
    return ProjectModel.fromJson(response.data);
  }

  Future<void> deleteProject(String id) async {
    await _apiClient.delete('/projects/$id');
  }
}
