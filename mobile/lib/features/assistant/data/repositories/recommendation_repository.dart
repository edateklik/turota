import 'package:turota_mobile/features/assistant/data/data_sources/recommendation_remote_data_source.dart';
import 'package:turota_mobile/features/assistant/data/dto/recommendation_dto.dart';

class RecommendationRepository {
  const RecommendationRepository(this._dataSource);

  final RecommendationRemoteDataSource _dataSource;

  Future<RecommendationAcceptedResponseDto> generateRecommendation(GenerateRecommendationRequestDto request) async {
    return await _dataSource.generateRecommendation(request);
  }

  Future<RecommendationRunResponseDto> getRecommendationStatus(String runId) async {
    return await _dataSource.getRecommendationStatus(runId);
  }
}
