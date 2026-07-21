import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/spatial_repository.dart';
import '../../data/dto/spatial_neighborhood_dto.dart';
import '../../data/dto/spatial_place_dto.dart';

final spatialRepositoryProvider = Provider<SpatialRepository>((ref) {
  return SpatialRepository();
});

class MapState {
  final List<SpatialNeighborhoodDto> neighborhoods;
  final List<SpatialPlaceDto> places;

  MapState({required this.neighborhoods, required this.places});
}

final mapControllerProvider = FutureProvider.autoDispose<MapState>((ref) async {
  final repository = ref.watch(spatialRepositoryProvider);

  // Focus on Kadıköy (Lat: 40.990, Lon: 29.020)
  final double lat = 40.990;
  final double lon = 29.020;

  final neighborhoods = await repository.getNearbyNeighborhoods(
    lat,
    lon,
    limit: 5,
  );

  final List<SpatialPlaceDto> allPlaces = [];
  for (var neighborhood in neighborhoods) {
    final places = await repository.getPlacesInNeighborhood(neighborhood.id);
    allPlaces.addAll(places);
  }

  return MapState(neighborhoods: neighborhoods, places: allPlaces);
});
