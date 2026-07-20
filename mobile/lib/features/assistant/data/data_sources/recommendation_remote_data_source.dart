import 'package:turota_mobile/core/networking/api_client.dart';
import 'package:turota_mobile/features/assistant/data/dto/recommendation_dto.dart';

class RecommendationRemoteDataSource {
  const RecommendationRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<RecommendationAcceptedResponseDto> generateRecommendation(GenerateRecommendationRequestDto request) async {
    final response = await _apiClient.post(
      '/api/recommendations/generate',
      body: request.toJson(),
    );
    return RecommendationAcceptedResponseDto.fromJson(response as Map<String, dynamic>);
  }

  Future<RecommendationRunResponseDto> getRecommendationStatus(String runId) async {
    final response = await _apiClient.get('/api/recommendations/$runId');
    return RecommendationRunResponseDto.fromJson(response as Map<String, dynamic>);
  }
}
