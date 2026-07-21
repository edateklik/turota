import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/data/dto/update_taste_profile_request_dto.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/domain/models/taste_profile_state.dart';

class EditTasteProfileController extends AsyncNotifier<TasteProfileState> {
  @override
  Future<TasteProfileState> build() async {
    return _fetchProfile();
  }

  Future<TasteProfileState> _fetchProfile() async {
    final repository = ref.read(authRepositoryProvider);
    try {
      final dto = await repository.getTasteProfile();
      return TasteProfileState(
        preferredCategoryIds: dto.preferredCategoryIds,
        preferredTagIds: dto.preferredTagIds,
        dietaryPreference: dto.dietaryPreference,
        budgetLevel: dto.budgetLevel,
        distancePreference: dto.distancePreference,
      );
    } catch (e) {
      return const TasteProfileState();
    }
  }

  void toggleCategory(String categoryId) {
    if (state.value == null) return;
    final current = List<String>.from(state.value!.preferredCategoryIds);
    if (current.contains(categoryId)) {
      current.remove(categoryId);
    } else {
      current.add(categoryId);
    }
    state = AsyncValue.data(state.value!.copyWith(preferredCategoryIds: current));
  }

  void toggleTag(String tagId) {
    if (state.value == null) return;
    final current = List<String>.from(state.value!.preferredTagIds);
    if (current.contains(tagId)) {
      current.remove(tagId);
    } else {
      current.add(tagId);
    }
    state = AsyncValue.data(state.value!.copyWith(preferredTagIds: current));
  }

  void setDietaryPreference(String preference) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(dietaryPreference: preference));
  }

  void setBudgetLevel(String level) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(budgetLevel: level));
  }

  void setDistancePreference(String preference) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(distancePreference: preference));
  }

  Future<void> saveProfile() async {
    if (state.value == null) return;
    final current = state.value!;
    final repository = ref.read(authRepositoryProvider);

    final request = UpdateTasteProfileRequestDto(
      preferredCategoryIds: current.preferredCategoryIds,
      preferredTagIds: current.preferredTagIds,
      dietaryPreference: current.dietaryPreference ?? 'NoPreference',
      budgetLevel: current.budgetLevel ?? 'Moderate',
      travelPace: 'Balanced', // Default for now
      distancePreference: current.distancePreference ?? 'Flexible',
    );

    await repository.updateTasteProfile(request);
  }
}

final editTasteProfileControllerProvider =
    AsyncNotifierProvider<EditTasteProfileController, TasteProfileState>(
  EditTasteProfileController.new,
);
