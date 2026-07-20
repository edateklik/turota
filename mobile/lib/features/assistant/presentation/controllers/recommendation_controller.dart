import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/features/assistant/data/dto/recommendation_dto.dart';
import 'package:turota_mobile/features/assistant/presentation/providers/recommendation_providers.dart';

class RecommendationState {
  final bool isLoading;
  final String? error;
  final RecommendationResponseDto? response;

  RecommendationState({
    this.isLoading = false,
    this.error,
    this.response,
  });

  RecommendationState copyWith({
    bool? isLoading,
    String? error,
    RecommendationResponseDto? response,
  }) {
    return RecommendationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      response: response ?? this.response,
    );
  }
}

class RecommendationController extends Notifier<RecommendationState> {
  Timer? _pollingTimer;

  @override
  RecommendationState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    return RecommendationState();
  }

  Future<void> generateRecommendation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(recommendationRepositoryProvider);
      final request = GenerateRecommendationRequestDto(
        availableMinutes: 120, // default dummy
      );

      final accepted = await repository.generateRecommendation(request);
      
      // Start polling
      _startPolling(accepted.runId);

    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startPolling(String runId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final repository = ref.read(recommendationRepositoryProvider);
        final runResponse = await repository.getRecommendationStatus(runId);

        if (runResponse.status == 'Completed' && runResponse.result != null) {
          timer.cancel();
          state = state.copyWith(isLoading: false, response: runResponse.result);
        } else if (runResponse.status == 'Failed') {
          timer.cancel();
          state = state.copyWith(isLoading: false, error: 'Yapay zeka rotayı oluştururken bir hata oluştu.');
        }
      } catch (e) {
        timer.cancel();
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    });
  }
}

final recommendationControllerProvider = NotifierProvider<RecommendationController, RecommendationState>(() {
  return RecommendationController();
});
