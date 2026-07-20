import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';

class OpeningHoursCard extends StatelessWidget {
  const OpeningHoursCard({required this.hours, super.key});

  final List<(String, String)> hours;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: const ValueKey('opening-hours-card'),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      borderColor: AppColors.savedOutlineVariant,
      child: Column(
        children: [
          for (var index = 0; index < hours.length; index++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    hours[index].$1,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.savedTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  hours[index].$2,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (index != hours.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }
}
