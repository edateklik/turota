import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/theme/app_typography.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.splashAnimationDuration,
      vsync: this,
    );
    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _fadeAnimation = curvedAnimation;
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _animationController.forward();
    _navigationTimer = Timer(
      AppConstants.splashDisplayDuration,
      _navigateToOnboarding,
    );
  }

  void _navigateToOnboarding() {
    if (!mounted || _hasNavigated) {
      return;
    }

    _hasNavigated = true;
    Navigator.of(context).pushReplacementNamed(AppRouter.locationPermission);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: const _SplashBranding(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashBranding extends StatelessWidget {
  const _SplashBranding();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            AppConstants.logoAssetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const _SplashLogoFallback(),
          ),
        ),
      ),
    );
  }
}

class _SplashLogoFallback extends StatelessWidget {
  const _SplashLogoFallback();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('splash-logo-fallback'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.explore_rounded, size: 96, color: AppColors.onPrimary),
        const SizedBox(height: AppSpacing.md),
        Text(
          AppConstants.brandName,
          textAlign: TextAlign.center,
          style: AppTypography.splashBrand.copyWith(color: AppColors.onPrimary),
        ),
      ],
    );
  }
}
