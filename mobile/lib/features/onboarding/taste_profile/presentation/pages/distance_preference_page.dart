import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/shared/widgets/onboarding_progress_bar.dart';
import 'package:turota_mobile/shared/widgets/turota_action_button.dart';
import '../controllers/taste_profile_controller.dart';
import 'package:turota_mobile/app/router/app_router.dart';

class DistancePreferencePage extends ConsumerWidget {
  const DistancePreferencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(tasteProfileControllerProvider);
    final controller = ref.read(tasteProfileControllerProvider.notifier);

    // Note: Options reflect backend DistancePreference values.
    final options = [
      {'value': 'WalkingDistance', 'label': 'Yürüme mesafesi'},
      {'value': 'Max3Km', 'label': 'En fazla 3 km'},
      {'value': 'Max10Km', 'label': 'En fazla 10 km'},
      {'value': 'CityWide', 'label': 'Şehir içinde fark etmez'},
      {'value': 'Flexible', 'label': 'Rotaya göre değişebilir'},
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 4,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'TUROTA',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.tasteProfileResult);
            },
            child: Text(
              'Skip',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OnboardingProgressBar(
              currentStep: 5,
              totalSteps: 5,
              title: 'Öneri puanının %10\'u',
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      children: [
                        Text(
                          'Öneriler sana ne kadar yakın olsun?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Başlangıç konumuna yakın mekanlar daha yüksek puan alır.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),

                        ...options.map((option) {
                          final isSelected =
                              state.distancePreference == option['value'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                controller.setDistancePreference(
                                  option['value']!,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primaryContainer
                                            .withOpacity(0.2)
                                      : colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.surfaceContainerHighest,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Custom Radio Indicator
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.outlineVariant,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: colorScheme
                                                      .surfaceContainerLowest,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    Expanded(
                                      child: Text(
                                        option['label']!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onBackground,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        // Note: Transportation options have been deliberately removed as per user request.
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed Bottom Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withOpacity(0.9),
                    colorScheme.surface.withOpacity(0),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: TurotaActionButton(
                  label: 'Devam Et',
                  onPressed: state.distancePreference != null
                      ? () {
                          // Push to results
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.tasteProfileResult);
                        }
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
