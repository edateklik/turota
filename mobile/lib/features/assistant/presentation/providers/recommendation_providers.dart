import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/core/providers/core_providers.dart';
import 'package:turota_mobile/features/assistant/data/data_sources/recommendation_remote_data_source.dart';
import 'package:turota_mobile/features/assistant/data/repositories/recommendation_repository.dart';

final recommendationDataSourceProvider =
    Provider<RecommendationRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return RecommendationRemoteDataSource(apiClient);
    });

final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  final dataSource = ref.watch(recommendationDataSourceProvider);
  return RecommendationRepository(dataSource);
});
