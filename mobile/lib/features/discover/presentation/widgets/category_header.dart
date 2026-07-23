import 'package:flutter/material.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/current_user_avatar.dart';

abstract final class CategoryImageAssets {
  static const gastronomy = 'assets/images/categories/gastronomy_category.jpg';
  static const artCulture = 'assets/images/categories/art_culture_category.jpg';
  static const cityLights = 'assets/images/categories/city_lights_category.jpg';
}

class CategoryHeader extends StatelessWidget implements PreferredSizeWidget {
  const CategoryHeader({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.imageSemanticLabel,
    this.logo = AppConstants.brandName,
    this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData fallbackIcon;
  final String imageSemanticLabel;
  final String logo;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(264);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.96),
      child: SafeArea(
        bottom: false,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: kToolbarHeight,
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                        ),
                        onPressed: onBack ?? () => Navigator.of(context).pop(),
                        tooltip: 'Geri',
                      ),
                    ),
                    Expanded(
                      child: Text(
                        logo,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 56,
                      child: Center(
                        child: CurrentUserAvatar(radius: 16, borderWidth: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _CategoryImage(
                      imageAsset: imageAsset,
                      fallbackIcon: fallbackIcon,
                      semanticLabel: imageSemanticLabel,
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

class CategorySectionHeader extends StatelessWidget {
  const CategorySectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            minimumSize: const Size(48, 48),
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({
    required this.imageAsset,
    required this.fallbackIcon,
    required this.semanticLabel,
  });

  static const diameter = 48.0;

  final String imageAsset;
  final IconData fallbackIcon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        key: const ValueKey('category-header-image'),
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            imageAsset,
            key: ValueKey(imageAsset),
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(
              fallbackIcon,
              key: const ValueKey('category-header-image-fallback'),
              size: 22,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
