import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class RouteBottomSheet extends StatelessWidget {
  const RouteBottomSheet({
    required this.onDetailsPressed,
    required this.onStartPressed,
    super.key,
  });

  final VoidCallback onDetailsPressed;
  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('route-bottom-sheet'),
      color: AppColors.surface,
      elevation: 10,
      shadowColor: AppColors.shadow,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.savedOutlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _CoffeeThumbnail(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sıradaki Durak',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Komorebi Coffee Roasters',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.savedTextPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '12 dk yürüme  •  0.8 km',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.savedTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('route-details-button'),
                    onPressed: onDetailsPressed,
                    child: const Text('Detaylar'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('start-route-button'),
                    onPressed: onStartPressed,
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Rotayı Başlat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoffeeThumbnail extends StatelessWidget {
  const _CoffeeThumbnail();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Komorebi Coffee için kahve illüstrasyonu',
      image: true,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3D8B6), Color(0xFF8B5E3C)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(
          Icons.coffee_rounded,
          color: AppColors.surface,
          size: 36,
        ),
      ),
    );
  }
}
