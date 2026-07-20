import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class TimelineSegmentedControl extends StatelessWidget {
  const TimelineSegmentedControl({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Plan görünümü seçimi',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.savedSurfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.savedOutlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Segment(
                key: const ValueKey('timeline-segment'),
                label: 'Zaman Çizelgesi',
                icon: Icons.view_timeline_rounded,
                isSelected: selectedIndex == 0,
                onPressed: () => onSelected(0),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: _Segment(
                key: const ValueKey('map-segment'),
                label: 'Harita',
                icon: Icons.map_outlined,
                isSelected: selectedIndex == 1,
                onPressed: () => onSelected(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        key: isSelected ? ValueKey('$label-selected') : null,
        color: isSelected
            ? AppColors.discoverPrimaryContainer
            : Colors.transparent,
        elevation: isSelected ? 2 : 0,
        shadowColor: AppColors.shadow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.savedOutline,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.savedOutline,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
