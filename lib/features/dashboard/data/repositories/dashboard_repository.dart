import '../../../../core/network/api_client.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<DashboardStatsModel> getStats() async {
    final response = await _apiClient.get('/dashboard/stats');
    return DashboardStatsModel.fromJson(response.data);
  }
}
