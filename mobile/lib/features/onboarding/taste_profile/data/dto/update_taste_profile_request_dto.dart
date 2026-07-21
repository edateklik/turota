class UpdateTasteProfileRequestDto {
  final List<String> preferredCategoryIds;
  final List<String> preferredTagIds;
  final String dietaryPreference;
  final String budgetLevel;
  final String travelPace;
  final String distancePreference;

  const UpdateTasteProfileRequestDto({
    this.preferredCategoryIds = const [],
    this.preferredTagIds = const [],
    required this.dietaryPreference,
    required this.budgetLevel,
    required this.travelPace,
    required this.distancePreference,
  });

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
