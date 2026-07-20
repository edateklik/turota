import '../data_sources/spatial_remote_data_source.dart';
import '../dto/spatial_neighborhood_dto.dart';
import '../dto/spatial_place_dto.dart';

class SpatialRepository {
  final SpatialRemoteDataSource _remoteDataSource;

  SpatialRepository({SpatialRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? SpatialRemoteDataSource();

  Future<List<SpatialNeighborhoodDto>> getNearbyNeighborhoods(double latitude, double longitude, {int limit = 5}) async {
    return await _remoteDataSource.getNearbyNeighborhoods(latitude, longitude, limit: limit);
  }

  Future<List<SpatialPlaceDto>> getPlacesInNeighborhood(String neighborhoodId) async {
    return await _remoteDataSource.getPlacesInNeighborhood(neighborhoodId);
  }
}
