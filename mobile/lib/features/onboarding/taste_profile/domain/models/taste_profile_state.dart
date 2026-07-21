import 'package:flutter/foundation.dart';

@immutable
class TasteProfileState {
  final List<String> preferredCategoryIds;
  final List<String> preferredTagIds;
  final String? dietaryPreference;
  final String? budgetLevel;
  final String? distancePreference;

  const TasteProfileState({
    this.preferredCategoryIds = const [],
    this.preferredTagIds = const [],
    this.dietaryPreference,
    this.budgetLevel,
    this.distancePreference,
  });

  TasteProfileState copyWith({
    List<String>? preferredCategoryIds,
    List<String>? preferredTagIds,
    String? dietaryPreference,
    String? budgetLevel,
    String? distancePreference,
  }) {
    return TasteProfileState(
      preferredCategoryIds: preferredCategoryIds ?? this.preferredCategoryIds,
      preferredTagIds: preferredTagIds ?? this.preferredTagIds,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      distancePreference: distancePreference ?? this.distancePreference,
    );
  }
}
