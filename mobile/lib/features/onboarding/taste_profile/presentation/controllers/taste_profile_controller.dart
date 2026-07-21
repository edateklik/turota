import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/taste_profile_state.dart';

class TasteProfileController extends Notifier<TasteProfileState> {
  @override
  TasteProfileState build() {
    return const TasteProfileState();
  }

  void toggleCategory(String categoryId) {
    final current = List<String>.from(state.preferredCategoryIds);
    if (current.contains(categoryId)) {
      current.remove(categoryId);
    } else {
      current.add(categoryId);
    }
    state = state.copyWith(preferredCategoryIds: current);
  }

  void toggleTag(String tagId) {
    final current = List<String>.from(state.preferredTagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    state = state.copyWith(preferredTagIds: current);
  }

  void setDietaryPreference(String preference) {
    state = state.copyWith(dietaryPreference: preference);
  }

  void setBudgetLevel(String budget) {
    state = state.copyWith(budgetLevel: budget);
  }

  void setDistancePreference(String distance) {
    state = state.copyWith(distancePreference: distance);
  }

  Future<void> saveProfile() async {
    // TODO: Connect to backend API via IdentityService/Repository
    // For now, we simulate a small delay to show loading state if needed.
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final tasteProfileControllerProvider =
    NotifierProvider<TasteProfileController, TasteProfileState>(
      TasteProfileController.new,
    );
