class SpatialNeighborhoodDto {
  final String id;
  final String name;
  final String cityId;
  final double distanceMeters;

  SpatialNeighborhoodDto({
    required this.id,
    required this.name,
    required this.cityId,
    required this.distanceMeters,
  });

  factory SpatialNeighborhoodDto.fromJson(Map<String, dynamic> json) {
    return SpatialNeighborhoodDto(
      id: json['id'] as String,
      name: json['name'] as String,
      cityId: json['cityId'] as String,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
    );
  }
}
