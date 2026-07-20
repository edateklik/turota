import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

enum SavedPlanVisual { karakoy, bosphorus, oldCity }

class SavedPlanCard extends StatelessWidget {
  const SavedPlanCard({
    required this.id,
    required this.title,
    required this.badge,
    required this.routeInfo,
    required this.duration,
    required this.visual,
    required this.isBookmarked,
    required this.onPressed,
    required this.onBookmarkPressed,
    super.key,
  });

  final String id;
  final String title;
  final String badge;
  final String routeInfo;
  final String duration;
  final SavedPlanVisual visual;
  final bool isBookmarked;
  final VoidCallback onPressed;
  final VoidCallback onBookmarkPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: '$title, $badge, $routeInfo, $duration',
      child: Material(
        color: AppColors.surface,
        elevation: 3,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.savedOutlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 168,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PlanIllustration(visual: visual),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Semantics(
                        button: true,
                        label: isBookmarked
                            ? '$title kaydını kaldır'
                            : '$title kaydet',
                        child: IconButton.filledTonal(
                          key: ValueKey('saved-plan-bookmark-$id'),
                          onPressed: onBookmarkPressed,
                          tooltip: isBookmarked
                              ? '$title kaydını kaldır'
                              : '$title kaydet',
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.savedAccentLight,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.savedTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _PlanMetadata(
                          icon: Icons.route_rounded,
                          label: routeInfo,
                        ),
                        Text(
                          '•',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.savedOutline,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        _PlanMetadata(
                          icon: Icons.schedule_rounded,
                          label: duration,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanMetadata extends StatelessWidget {
  const _PlanMetadata({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.savedTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlanIllustration extends StatelessWidget {
  const _PlanIllustration({required this.visual});

  final SavedPlanVisual visual;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: switch (visual) {
        SavedPlanVisual.karakoy => const _KarakoyIllustration(),
        SavedPlanVisual.bosphorus => const _BosphorusIllustration(),
        SavedPlanVisual.oldCity => const _OldCityIllustration(),
      },
    );
  }
}

class _KarakoyIllustration extends StatelessWidget {
  const _KarakoyIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFC27A), Color(0xFFE66A3D)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 22,
            left: 28,
            child: Icon(
              Icons.palette_outlined,
              size: 46,
              color: Color(0xCCFFFFFF),
            ),
          ),
          for (var index = 0; index < 4; index++)
            Positioned(
              left: 18.0 + (index * 62),
              bottom: 0,
              child: Container(
                width: 52,
                height: 72.0 + ((index % 2) * 30),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? const Color(0xFF9F3F32)
                      : const Color(0xFF6F3540),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sm),
                  ),
                ),
                child: const Icon(
                  Icons.window_rounded,
                  color: Color(0xFFFFD99B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BosphorusIllustration extends StatelessWidget {
  const _BosphorusIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE9FF), Color(0xFF238FBD)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -30,
            right: -30,
            bottom: -38,
            child: Container(
              height: 98,
              decoration: BoxDecoration(
                color: const Color(0xFF087AA8),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            top: 22,
            child: Icon(
              Icons.breakfast_dining_rounded,
              size: 48,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const Positioned(
            right: 56,
            bottom: 28,
            child: Icon(
              Icons.directions_boat_filled_rounded,
              size: 72,
              color: Color(0xFFF8FBFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _OldCityIllustration extends StatelessWidget {
  const _OldCityIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC7B5D9), Color(0xFF67507E)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 30,
            bottom: 0,
            child: Icon(
              Icons.account_balance_rounded,
              size: 108,
              color: Color(0xFF493852),
            ),
          ),
          Positioned(
            right: 48,
            bottom: 0,
            child: Container(
              width: 50,
              height: 132,
              decoration: const BoxDecoration(
                color: Color(0xFF382B46),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.pill),
                ),
              ),
              child: const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Icon(Icons.circle_outlined, color: Color(0xFFE5D8C8)),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 22,
            right: 24,
            child: Icon(
              Icons.auto_stories_outlined,
              size: 38,
              color: Color(0xE6FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}
