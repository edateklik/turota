import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../dto/spatial_neighborhood_dto.dart';
import '../dto/spatial_place_dto.dart';

class SpatialRemoteDataSource {
  final http.Client _client;
  final String _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:5121'
      : 'http://localhost:5121';

  SpatialRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<List<SpatialNeighborhoodDto>> getNearbyNeighborhoods(
    double latitude,
    double longitude, {
    int limit = 5,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/api/discovery/neighborhoods/nearby?latitude=$latitude&longitude=$longitude&limit=$limit',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((json) => SpatialNeighborhoodDto.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load nearby neighborhoods');
    }
  }

  Future<List<SpatialPlaceDto>> getPlacesInNeighborhood(
    String neighborhoodId,
  ) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/discovery/neighborhoods/$neighborhoodId/places'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SpatialPlaceDto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load places for neighborhood');
    }
  }

  Future<List<SpatialPlaceDto>> getNearestPlaces(
    double latitude,
    double longitude, {
    int limit = 10,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$_baseUrl/api/discovery/places/nearest?latitude=$latitude&longitude=$longitude&limit=$limit',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => SpatialPlaceDto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nearest places');
    }
  }
}
