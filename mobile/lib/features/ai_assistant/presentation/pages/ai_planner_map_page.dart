import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_bottom_navigation.dart';
import 'package:turota_mobile/core/widgets/app_scaffold.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/widgets/ai_route_map.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/widgets/route_bottom_sheet.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/widgets/timeline_segmented_control.dart';

class AiPlannerMapPage extends StatelessWidget {
  const AiPlannerMapPage({super.key});

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleBottomNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRouter.discover);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRouter.saved);
    } else if (index == 3) {
      _showMessage(context, 'Profil ekranı yakında eklenecek.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.savedBackground,
      padding: EdgeInsets.zero,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 2,
        onDestinationSelected: (index) =>
            _handleBottomNavigation(context, index),
      ),
      body: Column(
        children: [
          _MapAppBar(
            onBackPressed: () => Navigator.of(context).maybePop(),
            onMenuPressed: () =>
                _showMessage(context, 'Plan seçenekleri yakında eklenecek.'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: TimelineSegmentedControl(
                selectedIndex: 1,
                onSelected: (index) {
                  if (index == 0) {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRouter.aiPlannerTimeline);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: AiRouteMap(
                    onMapPressed: () => _showMessage(
                      context,
                      'Tam ekran harita yakında eklenecek.',
                    ),
                    onLocationPressed: () => _showMessage(
                      context,
                      'Harita entegrasyonu yakında eklenecek.',
                    ),
                    onFitRoutePressed: () => _showMessage(
                      context,
                      'Harita entegrasyonu yakında eklenecek.',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: RouteBottomSheet(
              onDetailsPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.placeDetail),
              onStartPressed: () =>
                  _showMessage(context, 'Navigasyon yakında eklenecek.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapAppBar extends StatelessWidget {
  const _MapAppBar({required this.onBackPressed, required this.onMenuPressed});

  final VoidCallback onBackPressed;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            Semantics(
              label: 'Karaköy rotasından geri dön',
              button: true,
              child: IconButton(
                key: const ValueKey('ai-map-back'),
                onPressed: onBackPressed,
                tooltip: 'Geri dön',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: Text(
                'Karaköy Rotası',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Semantics(
              label: 'Plan seçeneklerini aç',
              button: true,
              child: IconButton(
                key: const ValueKey('ai-map-menu'),
                onPressed: onMenuPressed,
                tooltip: 'Plan seçenekleri',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
