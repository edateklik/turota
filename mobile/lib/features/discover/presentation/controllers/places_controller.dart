import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/spatial_repository.dart';
import '../../data/dto/spatial_place_dto.dart';

final spatialRepositoryProvider = Provider<SpatialRepository>((ref) {
  return SpatialRepository();
});

final nearestPlacesControllerProvider =
    FutureProvider.autoDispose<List<SpatialPlaceDto>>((ref) async {
      final repository = ref.watch(spatialRepositoryProvider);
      // Default to a central Istanbul location (e.g. Sultanahmet)
      return await repository.getNearestPlaces(41.0082, 28.9784, limit: 3);
    });
