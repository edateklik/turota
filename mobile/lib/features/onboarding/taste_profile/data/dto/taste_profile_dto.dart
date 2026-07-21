class TasteProfileDto {
  final List<String> preferredCategoryIds;
  final List<String> preferredTagIds;
  final String dietaryPreference;
  final String budgetLevel;
  final String travelPace;
  final String distancePreference;

  const TasteProfileDto({
    this.preferredCategoryIds = const [],
    this.preferredTagIds = const [],
    required this.dietaryPreference,
    required this.budgetLevel,
    required this.travelPace,
    required this.distancePreference,
  });

  factory TasteProfileDto.fromJson(Map<String, dynamic> json) {
    return TasteProfileDto(
      preferredCategoryIds: (json['preferredCategoryIds'] as List?)?.cast<String>() ?? [],
      preferredTagIds: (json['preferredTagIds'] as List?)?.cast<String>() ?? [],
      dietaryPreference: json['dietaryPreference'] as String? ?? 'NoPreference',
      budgetLevel: json['budgetLevel'] as String? ?? 'Moderate',
      travelPace: json['travelPace'] as String? ?? 'Balanced',
      distancePreference: json['distancePreference'] as String? ?? 'Flexible',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredCategoryIds': preferredCategoryIds,
      'preferredTagIds': preferredTagIds,
      'dietaryPreference': dietaryPreference,
      'budgetLevel': budgetLevel,
      'travelPace': travelPace,
      'distancePreference': distancePreference,
    };
  }
}
