class SpatialPlaceDto {
  final String id;
  final String name;
  final String address;
  final String neighborhoodId;
  final String categoryId;
  final double longitude;
  final double latitude;
  final double? distanceMeters;

  SpatialPlaceDto({
    required this.id,
    required this.name,
    required this.address,
    required this.neighborhoodId,
    required this.categoryId,
    required this.longitude,
    required this.latitude,
    this.distanceMeters,
  });

  factory SpatialPlaceDto.fromJson(Map<String, dynamic> json) {
    return SpatialPlaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      neighborhoodId: json['neighborhoodId'] as String,
      categoryId: json['categoryId'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      distanceMeters: json['distanceMeters'] != null
          ? (json['distanceMeters'] as num).toDouble()
          : null,
    );
  }
}
