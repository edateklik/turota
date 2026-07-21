import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/shared/widgets/onboarding_progress_bar.dart';
import 'package:turota_mobile/shared/widgets/turota_action_button.dart';
import '../controllers/taste_profile_controller.dart';
import 'package:turota_mobile/app/router/app_router.dart';

class CategoryPreferencePage extends ConsumerWidget {
  const CategoryPreferencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(tasteProfileControllerProvider);
    final controller = ref.read(tasteProfileControllerProvider.notifier);

    // Mock Categories since we don't have API integration for this step yet
    final categories = [
      {'id': '30000000-0000-0000-0000-000000000002', 'name': 'Gastronomi', 'icon': Icons.restaurant},
      {'id': '30000000-0000-0000-0000-000000000005', 'name': 'Sanat ve Kültür', 'icon': Icons.palette},
      {'id': '30000000-0000-0000-0000-000000000003', 'name': 'Müze', 'icon': Icons.museum},
      {'id': '30000000-0000-0000-0000-000000000004', 'name': 'Doğa / Park', 'icon': Icons.park},
      {'id': '30000000-0000-0000-0000-000000000006', 'name': 'Alışveriş', 'icon': Icons.shopping_bag},
      {'id': '30000000-0000-0000-0000-000000000001', 'name': 'Kafe', 'icon': Icons.local_cafe},
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
              Navigator.of(context).pushNamed(AppRouter.tasteProfileTag);
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
              currentStep: 1,
              totalSteps: 5,
              title: 'Öneri puanının %35\'i',
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nelerle ilgilenirsin?',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sana en uygun mekanları ve rotaları önerebilmemiz için sevdiğin kategorileri seç.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: categories.map((category) {
                              final isSelected = state.preferredCategoryIds
                                  .contains(category['id']);
                              return ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      category['icon'] as IconData,
                                      size: 18,
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(category['name'] as String),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (_) {
                                  controller.toggleCategory(
                                    category['id'] as String,
                                  );
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
                                showCheckmark: false,
                              );
                            }).toList(),
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
                  onPressed: state.preferredCategoryIds.isNotEmpty
                      ? () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.tasteProfileTag);
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
