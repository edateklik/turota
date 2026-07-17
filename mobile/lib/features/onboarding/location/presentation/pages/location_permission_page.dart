import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_button.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';
import 'package:turota_mobile/core/widgets/app_progress_indicator.dart';
import 'package:turota_mobile/core/widgets/app_scaffold.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _hasNavigated = false;

  void _continueToTemporaryDestination() {
    if (!mounted || _hasNavigated) {
      return;
    }

    _hasNavigated = true;
    // TODO: Replace these temporary actions with the real location permission
    // and manual city selection flows before continuing to authentication.
    Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.onboardingBackground,
      padding: EdgeInsets.zero,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AppCard(
                    borderRadius: AppRadius.xxl,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppProgressIndicator(value: 1 / 3),
                        const SizedBox(height: AppSpacing.lg),
                        const _LocationIllustration(),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Konumunuzu etkinleştirin',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Size özel mahalle ve mekan önerileri alabilmek için '
                          'konum erişimine izin verin.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton(
                          label: 'Konuma İzin Ver',
                          icon: Icons.location_on_outlined,
                          onPressed: _continueToTemporaryDestination,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: 'Şehri Manuel Seç',
                          onPressed: _continueToTemporaryDestination,
                          isFullWidth: true,
                          variant: AppButtonVariant.outlined,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _continueToTemporaryDestination,
                          child: const Text('Belki daha sonra'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LocationIllustration extends StatelessWidget {
  const _LocationIllustration();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Image.asset(
            AppConstants.locationIllustrationAssetPath,
            key: const ValueKey('location-illustration-asset'),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const _LocationIllustrationFallback(),
          ),
        ),
      ),
    );
  }
}

class _LocationIllustrationFallback extends StatelessWidget {
  const _LocationIllustrationFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('location-illustration-fallback'),
      decoration: BoxDecoration(
        color: AppColors.illustrationBackground,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: AppSpacing.lg,
            top: AppSpacing.lg,
            child: Icon(Icons.map_outlined, size: 88, color: AppColors.border),
          ),
          const Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Icon(
              Icons.route_outlined,
              size: 96,
              color: AppColors.border,
            ),
          ),
          Container(
            width: 112,
            height: 112,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
