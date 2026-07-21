import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/shared/widgets/onboarding_progress_bar.dart';
import 'package:turota_mobile/shared/widgets/turota_action_button.dart';
import '../controllers/taste_profile_controller.dart';
import 'package:turota_mobile/app/router/app_router.dart';

class BudgetPreferencePage extends ConsumerWidget {
  const BudgetPreferencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(tasteProfileControllerProvider);
    final controller = ref.read(tasteProfileControllerProvider.notifier);

    // Note: Options reflect backend BudgetLevel values.
    final options = [
      {
        'value': 'Economy',
        'icon': Icons.savings_outlined,
        'title': 'Ekonomik',
        'subtitle': '₺ - Sokak lezzetleri ve uygun fiyatlı mekanlar',
      },
      {
        'value': 'Moderate',
        'icon': Icons.restaurant_menu,
        'title': 'Dengeli',
        'subtitle': '₺₺ - Orta segment restoranlar ve kafeler',
      },
      {
        'value': 'Premium',
        'icon': Icons.workspace_premium_outlined,
        'title': 'Premium',
        'subtitle': '₺₺₺ - Fine dining ve lüks mekanlar',
      },
      {
        'value': 'Mixed',
        'icon': Icons.shuffle,
        'title': 'Karışık',
        'subtitle': 'Ruh halime ve duruma göre değişir',
      },
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
              Navigator.of(context).pushNamed(AppRouter.tasteProfileDistance);
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
              currentStep: 4,
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
                          'Genel bütçe tercihin nedir?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Seçimine uygun fiyat aralığındaki mekanlar ön plana çıkarılır.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 32),

                        ...options.map((option) {
                          final isSelected =
                              state.budgetLevel == option['value'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                controller.setBudgetLevel(
                                  option['value'] as String,
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primaryContainer
                                            .withOpacity(0.1)
                                      : colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.surfaceContainerHighest,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme
                                                  .surfaceContainerHighest,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        option['icon'] as IconData,
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option['title'] as String,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color: colorScheme.onSurface,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            option['subtitle'] as String,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: colorScheme.primary,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                  onPressed: state.budgetLevel != null
                      ? () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.tasteProfileDistance);
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
