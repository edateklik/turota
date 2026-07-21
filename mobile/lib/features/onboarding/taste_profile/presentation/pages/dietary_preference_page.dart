import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/shared/widgets/onboarding_progress_bar.dart';
import 'package:turota_mobile/shared/widgets/turota_action_button.dart';
import '../controllers/taste_profile_controller.dart';
import 'package:turota_mobile/app/router/app_router.dart';

class DietaryPreferencePage extends ConsumerWidget {
  const DietaryPreferencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(tasteProfileControllerProvider);
    final controller = ref.read(tasteProfileControllerProvider.notifier);

    // Note: Options reflect backend DietaryPreference enum values.
    final options = [
      {'value': 'Everything', 'label': 'Her şeyi yerim'},
      {'value': 'Vegetarian', 'label': 'Vejetaryen'},
      {'value': 'Vegan', 'label': 'Vegan'},
      {'value': 'GlutenFree', 'label': 'Glütensiz'},
      {'value': 'NoPreference', 'label': 'Belirli tercihim yok'},
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
              // Skip logic
              Navigator.of(context).pushNamed(AppRouter.tasteProfileBudget);
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
              currentStep: 3,
              totalSteps: 5,
              title: 'Öneri puanının %15\'i',
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Background Elements
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yeme içme tercihin var mı?',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bu seçim, uygun seçenekleri bulunan mekanların öne çıkmasına yardımcı olur.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Options Wrap
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: options.map((option) {
                              final isSelected =
                                  state.dietaryPreference == option['value'];
                              return ChoiceChip(
                                label: Text(option['label']!),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    controller.setDietaryPreference(
                                      option['value']!,
                                    );
                                  }
                                },
                                labelStyle: theme.textTheme.labelMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                backgroundColor: colorScheme.surface,
                                selectedColor: colorScheme.primaryContainer
                                    .withOpacity(0.2),
                                side: BorderSide(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                showCheckmark: isSelected,
                                checkmarkColor: colorScheme.onPrimaryContainer,
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 48),
                          // Info Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Örneğin vegan seçersen, vegan seçeneği bulunan mekanlar daha yüksek puan alır.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
              padding: const EdgeInsets.fromLTRB(
                20,
                32,
                20,
                32,
              ), // Add bottom padding for safe area manually if SafeArea isn't wrapping it
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
                  onPressed: state.dietaryPreference != null
                      ? () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.tasteProfileBudget);
                        }
                      : null, // Disable if nothing selected
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
