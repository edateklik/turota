import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_button.dart';

enum TimelineStopVisual { coffee, gallery, flora }

class TimelineStopCard extends StatelessWidget {
  const TimelineStopCard({
    required this.category,
    required this.title,
    required this.duration,
    required this.walkingTime,
    required this.visual,
    required this.onDetailsPressed,
    required this.onLocationPressed,
    super.key,
  });

  final String category;
  final String title;
  final String duration;
  final String walkingTime;
  final TimelineStopVisual visual;
  final VoidCallback onDetailsPressed;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$category, $title, süre $duration, $walkingTime',
      child: Material(
        color: AppColors.surface,
        elevation: 3,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.savedOutlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            final visual = _TimelineVisual(type: this.visual);
            final content = _StopContent(
              category: category,
              title: title,
              duration: duration,
              walkingTime: walkingTime,
              onDetailsPressed: onDetailsPressed,
              onLocationPressed: onLocationPressed,
            );

            if (isWide) {
              return SizedBox(
                height: 230,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 190, child: visual),
                    Expanded(child: content),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 138, child: visual),
                content,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StopContent extends StatelessWidget {
  const _StopContent({
    required this.category,
    required this.title,
    required this.duration,
    required this.walkingTime,
    required this.onDetailsPressed,
    required this.onLocationPressed,
  });

  final String category;
  final String title;
  final String duration;
  final String walkingTime;
  final VoidCallback onDetailsPressed;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.savedAccentLight,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              _Metadata(icon: Icons.schedule_rounded, label: duration),
              _Metadata(
                icon: Icons.directions_walk_rounded,
                label: walkingTime,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _StopActions(
            title: title,
            onDetailsPressed: onDetailsPressed,
            onLocationPressed: onLocationPressed,
          ),
        ],
      ),
    );
  }
}

class _StopActions extends StatelessWidget {
  const _StopActions({
    required this.title,
    required this.onDetailsPressed,
    required this.onLocationPressed,
  });

  final String title;
  final VoidCallback onDetailsPressed;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final details = AppButton(
          label: 'Detaylar',
          icon: Icons.arrow_forward_rounded,
          iconPosition: AppButtonIconPosition.trailing,
          onPressed: onDetailsPressed,
          isFullWidth: true,
        );
        final location = Tooltip(
          message: '$title konumunu göster',
          child: OutlinedButton.icon(
            onPressed: onLocationPressed,
            icon: const Icon(Icons.location_on_outlined),
            label: const Text('Konum'),
          ),
        );

        if (constraints.maxWidth < 260) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              details,
              const SizedBox(height: AppSpacing.sm),
              SizedBox(height: 52, child: location),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: details),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(height: 52, child: location),
          ],
        );
      },
    );
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _TimelineVisual extends StatelessWidget {
  const _TimelineVisual({required this.type});

  final TimelineStopVisual type;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: switch (type) {
        TimelineStopVisual.coffee => const _CoffeeVisual(),
        TimelineStopVisual.gallery => const _GalleryVisual(),
        TimelineStopVisual.flora => const _FloraVisual(),
      },
    );
  }
}

class _CoffeeVisual extends StatelessWidget {
  const _CoffeeVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE8C7), Color(0xFF9A6548)],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 22,
            top: 22,
            child: Icon(Icons.spa_outlined, size: 52, color: Color(0xFF4F684B)),
          ),
          const Center(
            child: Icon(
              Icons.coffee_rounded,
              size: 74,
              color: Color(0xFF5F3928),
            ),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: Container(
              width: 56,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1DA),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryVisual extends StatelessWidget {
  const _GalleryVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EFF0),
      child: Stack(
        children: [
          Positioned(
            left: 24,
            top: 22,
            child: Container(width: 64, height: 64, color: AppColors.primary),
          ),
          Positioned(
            right: 24,
            bottom: 20,
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFB6DADD),
                  border: Border.all(
                    color: AppColors.primaryContainer,
                    width: 5,
                  ),
                ),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.museum_rounded,
              size: 64,
              color: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloraVisual extends StatelessWidget {
  const _FloraVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDF0D2), Color(0xFF65875E)],
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 14,
            child: Icon(Icons.eco_rounded, size: 92, color: Color(0xFF31583C)),
          ),
          Positioned(
            right: 22,
            top: 20,
            child: Icon(
              Icons.restaurant_rounded,
              size: 58,
              color: Color(0xFFFFF0D3),
            ),
          ),
          Positioned(
            right: 32,
            bottom: 18,
            child: Icon(
              Icons.local_florist_rounded,
              size: 58,
              color: Color(0xFF456A49),
            ),
          ),
        ],
      ),
    );
  }
}
